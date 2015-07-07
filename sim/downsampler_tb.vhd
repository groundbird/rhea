-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/07/02 13:24:21
-- Design Name: 
-- Module Name: downsampler_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
-----------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;
use IEEE.STD_LOGIC_MISC.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.rhea_pkg.all;

entity downsampler_tb is
end entity downsampler_tb;

architecture Behavioral of downsampler_tb is

  constant clk_period : time := 5 ns;   -- 200 MHz

  signal clk     : std_logic;
  signal rst     : std_logic;
  signal sft_rst : std_logic;

  component iq_reader is
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      req      : in  std_logic;
      fmt_busy : in  std_logic;
      valid    : out std_logic;
      busy     : out std_logic;
      ack      : out std_logic);
  end component iq_reader;

  signal iq_req  : std_logic := '0';
  signal iq_en   : std_logic := '0';
  signal iq_busy : std_logic := '0';
  signal iq_ack  : std_logic := '0';

  component formatter is
    generic (
      d_size : integer);                -- bytes
    port (
      clk    : in     std_logic;
      rst    : in     std_logic;
      ts_rst : in     std_logic;
      en     : in     std_logic;
      din    : in     byte_array(d_size-1 downto 0);
      valid  : out    std_logic;
      busy   : out    std_logic;
      ack    : buffer std_logic;
      dout   : out    std_logic_vector(7 downto 0));
  end component formatter;

  -- Common
  signal fmt_busy         : std_logic;
  signal chunk_data       : std_logic_vector(7 downto 0);
  -- ADC Snapshot
  signal adc_ss_fmt_valid : std_logic;
  signal adc_ss_fmt_busy  : std_logic;
  signal adc_ss_fmt_ack   : std_logic;
  signal adc_ss_fmt_chunk : std_logic_vector(7 downto 0);
  -- I/Q Data Downsample
  signal iq_fmt_valid     : std_logic;
  signal iq_fmt_busy      : std_logic;
  signal iq_fmt_ack       : std_logic;
  signal iq_fmt_chunk     : std_logic_vector(7 downto 0);

  signal fmt_iq_data : byte_array(N_CHANNEL*IQ_DATA_WIDTH/4-1 downto 0);

  component downsampler is
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      din   : in  std_logic_vector(30 downto 0);
      dout  : out std_logic_vector(IQ_DATA_WIDTH-1 downto 0);
      valid : out std_logic);
  end component downsampler;

  signal ds_din   : std_logic_vector(30 downto 0);
  signal ds_valid : std_logic := '0';

  signal ds_i_valid : std_logic_vector(N_CHANNEL-1 downto 0) := (others => '0');
  signal ds_q_valid : std_logic_vector(N_CHANNEL-1 downto 0) := (others => '0');

  signal i_data_ds : iq_array;
  signal q_data_ds : iq_array;

  signal ds_dout : std_logic_vector(IQ_DATA_WIDTH-1 downto 0) := (others => '0');

begin

  ---------------------------------------------------------------------------
  -- IQ Reader
  ---------------------------------------------------------------------------
  IQ_Reader_inst : iq_reader
    port map (
      clk      => clk,
      rst      => rst,
      req      => iq_req,
      fmt_busy => fmt_busy,
      valid    => iq_en,
      busy     => iq_busy,
      ack      => iq_ack);

  ---------------------------------------------------------------------------
  -- Formatter
  ---------------------------------------------------------------------------
  sft_rst  <= iq_req;
  fmt_busy <= iq_fmt_busy;
  ds_valid <= and_reduce(ds_i_valid & ds_q_valid);

  IQ_Data_Formatter_inst : formatter
    generic map (
      d_size => N_CHANNEL*IQ_DATA_WIDTH/4)  -- bytes
    port map (
      -- in
      clk    => clk,
      rst    => rst,
      ts_rst => sft_rst,
      en     => ds_valid and iq_en,
      din    => fmt_iq_data,
      -- out
      valid  => iq_fmt_valid,
      busy   => iq_fmt_busy,
      ack    => iq_fmt_ack,
      dout   => iq_fmt_chunk);

  Convert_iqarray_to_byte_array : for i in 0 to N_CHANNEL-1 generate
    Serialize_IQ_Data : for j in 0 to IQ_DATA_WIDTH/8-1 generate
      fmt_iq_data(IQ_DATA_WIDTH/4*(i+1)-j-8) <= i_data_ds(i)(8*j+7 downto 8*j);
      fmt_iq_data(IQ_DATA_WIDTH/4*(i+1)-j-1) <= q_data_ds(i)(8*j+7 downto 8*j);
    end generate Serialize_IQ_Data;
  end generate Convert_iqarray_to_byte_array;

  IQ_Downsample : for i in 0 to N_CHANNEL-1 generate
    -------------------------------------------------------------------------
    -- Downsample
    -------------------------------------------------------------------------
    Downsample_I : downsampler
      port map (
        -- in
        clk   => clk,
        rst   => rst,
        din   => ds_din,
        -- out
        dout  => i_data_ds(i),
        valid => ds_i_valid(i));

    Downsample_Q : downsampler
      port map (
        -- in
        clk   => clk,
        rst   => rst,
--        din   => ds_din+'1',
        din => conv_std_logic_vector(1, 31),
        -- out
        dout  => q_data_ds(i),
        valid => ds_q_valid(i));
  end generate IQ_Downsample;

  ---------------------------------------------------------------------------
  -- Clock
  ---------------------------------------------------------------------------
  Sys_CLK_proc : process
  begin
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
  end process;

  ---------------------------------------------------------------------------
  -- Stimulus Process (Main)
  ---------------------------------------------------------------------------
  stim_proc : process
  begin
    rst <= '1';
    wait for clk_period*3;
    rst <= '0';

    wait for clk_period*50;

    iq_req <= '1';
    wait for clk_period;
    iq_req <= '0';

    wait for clk_period*100;

    iq_req <= '1';
    wait for clk_period;
    iq_req <= '0';

    wait;
  end process;

  process(clk)
    variable cnt : integer;
  begin
    if rising_edge(clk) then
      if rst = '1' or ds_valid = '1' then
        cnt    := 0;
        ds_din <= (others => '0');
      else
        cnt    := cnt + 1;
        ds_din <= conv_std_logic_vector(cnt, 31);
      end if;
    end if;
  end process;
  
end Behavioral;
