-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/05/26 22:39:20
-- Design Name: 
-- Module Name: formatter_sim - Behavioral
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

entity formatter_sim is
end formatter_sim;

architecture Behavioral of formatter_sim is

  constant clk_period : time    := 5 ns;  -- 200 MHz
  constant d_size     : integer := 4;

  signal clk : std_logic;
  signal rst : std_logic;

  component formatter is
    generic (
      d_size : integer);                -- bytes
    port (
      clk              : in     std_logic;
      rst              : in     std_logic;
      ts_rst           : in     std_logic;
      en               : in     std_logic;
      fifo_almost_full : in     std_logic;
      din              : in     byte_array(d_size-1 downto 0);
      fifo_wr_en       : out    std_logic;
      busy             : out    std_logic;
      ack              : buffer std_logic;
      dout             : out    std_logic_vector(7 downto 0));
  end component formatter;

  signal ts_rst           : std_logic;
  signal fmt_en           : std_logic;
  signal fifo_almost_full : std_logic;
  signal fmt_din          : byte_array(d_size-1 downto 0);
  signal fifo_wr_en       : std_logic;
  signal fmt_busy         : std_logic;
  signal fmt_ack          : std_logic;
  signal fmt_dout         : std_logic_vector(7 downto 0);

  component adc_snapshot is
    port (
      clk        : in     std_logic;
      rst        : in     std_logic;
      en         : in     std_logic;
      fmt_busy   : in     std_logic;
      adc_data_a : in     std_logic_vector(13 downto 0);
      adc_data_b : in     std_logic_vector(13 downto 0);
      dout       : out    byte_array(3 downto 0);
      rd_en      : buffer std_logic;
      ack        : out    std_logic);
  end component adc_snapshot;

  signal adc_ss_en  : std_logic;
  signal adc_data_a : std_logic_vector(13 downto 0);
  signal adc_data_b : std_logic_vector(13 downto 0);
  signal adc_ss_ack : std_logic;

begin

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
  -- Data Format
  ---------------------------------------------------------------------------
  Formatter_inst : formatter
    generic map (
      d_size => d_size)
    port map (
      clk              => clk,
      rst              => rst,
      ts_rst           => ts_rst,
      en               => fmt_en,
      fifo_almost_full => fifo_almost_full,
      din              => fmt_din,
      fifo_wr_en       => fifo_wr_en,
      busy             => fmt_busy,
      ack              => fmt_ack,
      dout             => fmt_dout);

  ---------------------------------------------------------------------------
  -- ADC Snapshot
  ---------------------------------------------------------------------------
  ADC_Snapshot_inst : adc_snapshot
    port map (
      clk        => clk,
      rst        => rst,
      en         => adc_ss_en,
      fmt_busy   => fmt_busy,
      adc_data_a => adc_data_a,
      adc_data_b => adc_data_b,
      dout       => fmt_din,
      rd_en      => fmt_en,
      ack        => adc_ss_ack);

  ---------------------------------------------------------------------------
  -- Stimulus Process (Main)
  ---------------------------------------------------------------------------
  stim_proc : process
  begin

    -- init.
    rst              <= '1';
    ts_rst           <= '1';
    fifo_almost_full <= '0';
    adc_data_a       <= (others => '0');
    adc_data_b       <= (others => '0');
    adc_ss_en        <= '0';

    wait for clk_period*3;
    rst    <= '0';
    ts_rst <= '0';

    wait for clk_period*10;

    -- 1st
    adc_ss_en  <= '1';
    adc_data_a <= "000000" & x"11";
    adc_data_b <= "000000" & x"22";
    wait for clk_period;
    adc_ss_en  <= '0';

--    wait for 15*clk_period;

--    -- 2nd
--    wr_en <= '1';
--    din   <= (others => x"22");
--    wait for clk_period;
--    wr_en <= '0';
--    din   <= (others => x"00");

--    wait for 15*clk_period;

--    -- 3rd
--    wr_en <= '1';
--    din   <= (others => x"33");
--    wait for clk_period;
--    wr_en <= '0';
--    din   <= (others => x"00");

    wait;
  end process;

end Behavioral;
