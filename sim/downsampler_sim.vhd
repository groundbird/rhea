-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/06/24 15:57:26
-- Design Name: 
-- Module Name: downsampler_sim - Behavioral
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

entity downsampler_sim is
end entity downsampler_sim;

architecture Behavioral of downsampler_sim is

  constant clk_period : time := 5 ns;   -- 200 MHz

  signal clk : std_logic;
  signal rst : std_logic;

  signal sft_rst    : std_logic := '0';
  signal adc_ss_trg : std_logic := '0';

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
  signal fmt_busy         : std_logic                    := '0';
  signal chunk_data       : std_logic_vector(7 downto 0) := (others => '0');
  -- ADC Snapshot
  signal adc_ss_fmt_valid : std_logic                    := '0';
  signal adc_ss_fmt_busy  : std_logic                    := '0';
  signal adc_ss_fmt_ack   : std_logic                    := '0';
  signal adc_ss_fmt_chunk : std_logic_vector(7 downto 0) := (others => '0');
  -- Downsampler
  signal iq_fmt_valid     : std_logic                    := '0';
  signal iq_fmt_busy      : std_logic                    := '0';
  signal iq_fmt_ack       : std_logic                    := '0';
  signal iq_fmt_chunk     : std_logic_vector(7 downto 0) := (others => '0');

  signal fmt_iq_data : byte_array(N_CHANNEL*IQ_DATA_WIDTH/4-1 downto 0);

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

  component dac is
    port (
      clk      : in  std_logic;
      clk_2x   : in  std_logic;
      rst      : in  std_logic;
      din_a    : in  std_logic_vector(15 downto 0);
      din_b    : in  std_logic_vector(15 downto 0);
      dclk_p   : out std_logic;
      dclk_n   : out std_logic;
      frame_p  : out std_logic;
      frame_n  : out std_logic;
      dout_p   : out std_logic_vector(7 downto 0);
      dout_n   : out std_logic_vector(7 downto 0);
      txenable : out std_logic);
  end component dac;

  signal clk_2x   : std_logic;
  signal clk_div  : std_logic;
  signal dclk_p   : std_logic                    := '0';
  signal dclk_n   : std_logic                    := '0';
  signal frame_p  : std_logic                    := '0';
  signal frame_n  : std_logic                    := '0';
  signal dout_p   : std_logic_vector(7 downto 0) := (others => '0');
  signal dout_n   : std_logic_vector(7 downto 0) := (others => '0');
  signal txenable : std_logic                    := '0';

  component dds is
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      en    : in  std_logic;
      pinc  : in  std_logic_vector(31 downto 0);
      valid : out std_logic;
      cos   : out std_logic_vector(15 downto 0);
      sin   : out std_logic_vector(15 downto 0);
      busy  : out std_logic;
      ack   : out std_logic);
  end component dds;

  signal dds_en    : std_logic                     := '0';
  signal pinc      : std_logic_vector(31 downto 0) := (others => '0');
  signal dds_valid : std_logic                     := '0';
  signal cos       : std_logic_vector(15 downto 0) := (others => '0');
  signal sin       : std_logic_vector(15 downto 0) := (others => '0');
  signal busy      : std_logic                     := '0';
  signal ack       : std_logic                     := '0';

  component ddc is
    port (
      clk    : in  std_logic;
      rst    : in  std_logic;
      adcd_a : in  std_logic_vector(13 downto 0);
      adcd_b : in  std_logic_vector(13 downto 0);
      cos    : in  std_logic_vector(15 downto 0);
      sin    : in  std_logic_vector(15 downto 0);
      iout   : out std_logic_vector(30 downto 0);
      qout   : out std_logic_vector(30 downto 0));
  end component ddc;

  signal iarray : std_logic_vector(30 downto 0) := (others => '0');
  signal qarray : std_logic_vector(30 downto 0) := (others => '0');

  component downsampler is
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      din   : in  std_logic_vector(30 downto 0);
      dout  : out std_logic_vector(IQ_DATA_WIDTH-1 downto 0);
      valid : out std_logic);
  end component downsampler;

  signal ds_valid  : std_logic                              := '0';
  signal dsi_valid : std_logic_vector(N_CHANNEL-1 downto 0) := (others => '0');
  signal dsq_valid : std_logic_vector(N_CHANNEL-1 downto 0) := (others => '0');
  signal i_data_ds : iq_array                               := (others => x"00000000000000");
  signal q_data_ds : iq_array                               := (others => x"00000000000000");

begin

  sft_rst <= adc_ss_trg or dds_en or iq_req;

  ---------------------------------------------------------------------------
  -- Data Format for SiTCP
  ---------------------------------------------------------------------------
  fmt_busy <= adc_ss_fmt_busy or iq_fmt_busy;

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

  ds_valid <= and_reduce(dsi_valid & dsq_valid);

  Convert_iqarray_to_byte_array : for i in 0 to N_CHANNEL-1 generate
    Serialize_IQ_Data : for j in 0 to IQ_DATA_WIDTH/8-1 generate
      fmt_iq_data(IQ_DATA_WIDTH/4*i + j)                 <= i_data_ds(i)(8*j+7 downto 8*j);
      fmt_iq_data(IQ_DATA_WIDTH/4*i + j+IQ_DATA_WIDTH/8) <= q_data_ds(i)(8*j+7 downto 8*j);
    end generate Serialize_IQ_Data;
  end generate Convert_iqarray_to_byte_array;

  --------------------------------------------------------------------------
  -- IQ Reader
  --------------------------------------------------------------------------
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
  -- DAC
  ---------------------------------------------------------------------------
  DAC_inst : dac
    port map (
      clk      => clk,
      clk_2x   => clk_2x,
      rst      => rst,
--      din_a    => cos,
--      din_b    => sin,
      din_a    => x"0001",
      din_b    => x"0000",
      dclk_p   => dclk_p,
      dclk_n   => dclk_n,
      frame_p  => frame_p,
      frame_n  => frame_n,
      dout_p   => dout_p,
      dout_n   => dout_n,
      txenable => txenable);

  Demodulation : for i in 0 to N_CHANNEL-1 generate
    -------------------------------------------------------------------------
    -- DDS
    -------------------------------------------------------------------------
    DDS_inst : dds
      port map (
        clk   => clk,
        rst   => rst,
        en    => dds_en,
        pinc  => pinc,
        valid => dds_valid,
        cos   => cos,
        sin   => sin,
        busy  => busy,
        ack   => ack);

    -------------------------------------------------------------------------
    -- DDC
    -------------------------------------------------------------------------
    DDC_inst : ddc
      port map (
        clk    => clk,
        rst    => rst,
--        adcd_a => cos(15 downto 2),
--        adcd_b => sin(15 downto 2),
        adcd_a => x"000" & "01",
        adcd_b => (others => '0'),
        cos    => cos,
        sin    => sin,
        iout   => iarray,
        qout   => qarray);

    -------------------------------------------------------------------------
    -- Downsample
    -------------------------------------------------------------------------
    Downsample_I : downsampler
      port map (
        clk   => clk,
        rst   => rst,
        din   => iarray,
        dout  => i_data_ds(i),
        valid => dsi_valid(i));

    Downsample_Q : downsampler
      port map (
        clk   => clk,
        rst   => rst,
        din   => qarray,
        dout  => q_data_ds(i),
        valid => dsq_valid(i));
  end generate Demodulation;

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

  Sys_CLK_2x_proc : process
  begin
    clk_2x <= '1';
    wait for clk_period/4;
    clk_2x <= '0';
    wait for clk_period/4;
  end process;

  Sys_CLK_div_proc : process
  begin
    clk_div <= '1';
    wait for clk_period;
    clk_div <= '0';
    wait for clk_period;
  end process;

  ---------------------------------------------------------------------------
  -- Stimulus Process (Main)
  ---------------------------------------------------------------------------
  stim_proc : process
  begin

    -- init.
    rst    <= '1';
    dds_en <= '0';
    pinc   <= (others => '0');

    wait for clk_period*3;
    rst <= '0';

    wait for clk_period*10;

    dds_en <= '1';
    pinc   <= conv_std_logic_vector(1073741824, 32);  -- fout = 50 MHz
    wait for clk_period;
    dds_en <= '0';

--    wait for clk_period*5;
--    ds_en <= '1';

    wait for clk_period*30;

    dds_en <= '1';
    iq_req <= '1';
    pinc   <= conv_std_logic_vector(214748364, 32);  -- fout = 10 MHz
    wait for clk_period;
    dds_en <= '0';
    iq_req <= '0';

    wait for clk_period*200;
    iq_req <= '1';
    wait for clk_period;
    iq_req <= '0';

--    dds_en <= '1';
--    pinc   <= conv_std_logic_vector(536870912, 32);  -- fout = 25 MHz
--    wait for clk_period;
--    dds_en <= '0';

    wait;
  end process;
  
end Behavioral;
