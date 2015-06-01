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

  signal clk  : std_logic;
  signal bufa : std_logic_vector(13 downto 0) := (others => '0');
  signal bufb : std_logic_vector(13 downto 0) := (others => '0');

  component adc_snapshot is
    port (
      clk        : in  std_logic;
      rst        : in  std_logic;
      trg        : in  std_logic;
      adc_data_a : in  std_logic_vector(13 downto 0);
      adc_data_b : in  std_logic_vector(13 downto 0);
      dout       : out std_logic_vector(7 downto 0);
      fifo_wr_en : out std_logic;
      busy       : out std_logic;
      ack        : out std_logic);
  end component adc_snapshot;

  signal rst        : std_logic;
  signal adc_ss_trg : std_logic;
  signal adc_data_a : std_logic_vector(13 downto 0);
  signal adc_data_b : std_logic_vector(13 downto 0);
  signal dout       : std_logic_vector(7 downto 0);
  signal fifo_wr_en : std_logic;
  signal busy       : std_logic;
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
  -- ADC Snapshot
  ---------------------------------------------------------------------------
  ADC_Snapshot_inst : adc_snapshot
    port map (
      clk        => clk,
      rst        => rst,
      trg        => adc_ss_trg,
      adc_data_a => adc_data_a,
      adc_data_b => adc_data_b,
      dout       => dout,
      fifo_wr_en => fifo_wr_en,
      busy       => busy,
      ack        => adc_ss_ack);

  ---------------------------------------------------------------------------
  -- Stimulus Process (Main)
  ---------------------------------------------------------------------------
  stim_proc : process
  begin

    -- init.
    rst        <= '1';

    wait for clk_period;
    rst <= '0';

    wait for clk_period*3;
    adc_ss_trg <= '1';

    wait for clk_period;
    adc_ss_trg <= '0';

    wait;
  end process;

  ---------------------------------------------------------------------------
  -- ADC
  ---------------------------------------------------------------------------
  adc_data_a <= bufa;
  adc_data_b <= bufb;

--  adc_proc : process
--  begin
--    bufa <= bufa + '1';
--    bufb <= bufb + '1';
--    wait for clk_period;
--  end process;

end Behavioral;
