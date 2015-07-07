-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/05/25 20:38:03
-- Design Name: 
-- Module Name: adc_snapshot_sim - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library work;
use work.rhea_pkg.all;

entity adc_snapshot_sim is
end adc_snapshot_sim;

architecture Behavioral of adc_snapshot_sim is

  constant clk_period : time := 5 ns;   -- 200 MHz

  signal clk     : std_logic;
  signal rst     : std_logic;
  signal sft_rst : std_logic;

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

  signal fmt_ss_valid : std_logic;
  signal fmt_ss_busy  : std_logic;
  signal fmt_ss_ack   : std_logic;
  signal fmt_ss_data  : std_logic_vector(7 downto 0);

  component adc_snapshot is
    port (
      clk           : in     std_logic;
      rst           : in     std_logic;
      en            : in     std_logic;
      fmt_busy      : in     std_logic;
      din_a         : in     std_logic_vector(13 downto 0);
      din_b         : in     std_logic_vector(13 downto 0);
      wr_data_count : in     std_logic_vector(16 downto 0);
      dout          : out    byte_array(3 downto 0);
      valid         : buffer std_logic;
      ack           : out    std_logic);
  end component adc_snapshot;

  signal adc_ss_en     : std_logic                     := '0';
  signal fmt_busy      : std_logic                     := '0';
  signal wr_data_count : std_logic_vector(16 downto 0) := (others => '0');
  signal adc_ss_data   : byte_array(3 downto 0);
  signal adc_ss_valid  : std_logic;
  signal adc_ss_ack    : std_logic;

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
  signal dds_valid : std_logic;
  signal cos       : std_logic_vector(15 downto 0);
  signal sin       : std_logic_vector(15 downto 0);
  signal dds_busy  : std_logic;
  signal dds_ack   : std_logic;

begin

  ---------------------------------------------------------------------------
  -- Reset
  ---------------------------------------------------------------------------
  sft_rst <= adc_ss_en;
  
  ---------------------------------------------------------------------------
  -- Clock
  ---------------------------------------------------------------------------
  Clock_proc : process
  begin
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
  end process;

  ---------------------------------------------------------------------------
  -- Formatter for ADC Snapshot
  ---------------------------------------------------------------------------
  Formatter_for_ADC_Snapshot : formatter
    generic map (
      d_size => 4)
    port map (
      -- in
      clk    => clk,
      rst    => rst,
      ts_rst => sft_rst,
      en     => adc_ss_valid,
      din    => adc_ss_data,
      -- out
      valid  => fmt_ss_valid,
      busy   => fmt_ss_busy,
      ack    => fmt_ss_ack,
      dout   => fmt_ss_data);

  ---------------------------------------------------------------------------
  -- ADC Snapshot
  ---------------------------------------------------------------------------
  ADC_Snapshot_inst : adc_snapshot
    port map (
      -- in
      clk           => clk,
      rst           => rst,
      en            => adc_ss_en,
      fmt_busy      => fmt_busy,
      din_a         => cos(15 downto 2),
      din_b         => sin(15 downto 2),
      wr_data_count => wr_data_count,
      -- out
      dout          => adc_ss_data,
      valid         => adc_ss_valid,
      ack           => adc_ss_ack);

  ---------------------------------------------------------------------------
  -- DDS
  ---------------------------------------------------------------------------
  DDS_inst : dds
    port map (
      -- in
      clk   => clk,
      rst   => rst,
      en    => dds_en,
      pinc  => pinc,
      -- out
      valid => dds_valid,
      cos   => cos,
      sin   => sin,
      busy  => dds_busy,
      ack   => dds_ack);

  ---------------------------------------------------------------------------
  -- Stimulus Process (Main)
  ---------------------------------------------------------------------------
  stim_proc : process
  begin

    -- init.
    rst <= '1';
    wait for clk_period*3;
    rst <= '0';

    wait for clk_period*5;

    dds_en <= '1';
    pinc   <= conv_std_logic_vector(21474836, 32);  -- 1 MHz
    wait for clk_period;
    dds_en <= '0';

    wait for clk_period*10;

    adc_ss_en <= '1';
    wait for clk_period;
    adc_ss_en <= '0';

    wait;
  end process;

end Behavioral;
