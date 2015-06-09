-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/04/08 13:26:59
-- Design Name: 
-- Module Name: adc - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity adc is
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    -- ADC4249 I/O
    cha_p  : in  std_logic_vector(6 downto 0);
    cha_n  : in  std_logic_vector(6 downto 0);
    chb_p  : in  std_logic_vector(6 downto 0);
    chb_n  : in  std_logic_vector(6 downto 0);
    dout_a : out std_logic_vector(13 downto 0);
    dout_b : out std_logic_vector(13 downto 0));
end adc;

architecture Behavioral of adc is

  signal a_ddr : std_logic_vector(6 downto 0);
  signal b_ddr : std_logic_vector(6 downto 0);

begin

  ADC_Data : for i in 0 to 6 generate
    Channel_A_IBUFDS_inst : IBUFDS
      generic map (
        DIFF_TERM    => false,
        IBUF_LOW_PWR => true,
        IOSTANDARD   => "lvds_25")
      port map (
        O  => a_ddr(i),
        I  => cha_p(i),
        IB => cha_n(i));

    Channel_B_IBUFDS_inst : IBUFDS
      generic map (
        DIFF_TERM    => false,
        IBUF_LOW_PWR => true,
        IOSTANDARD   => "lvds_25")
      port map (
        O  => b_ddr(i),
        I  => chb_p(i),
        IB => chb_n(i));

    Channel_A_IDDR_inst : IDDR
      generic map (
        DDR_CLK_EDGE => "OPPOSITE_EDGE",
        INIT_Q1      => '0',
        INIT_Q2      => '0',
        SRTYPE       => "ASYNC")
      port map (
        Q1 => dout_a(2*i),
        Q2 => dout_a(2*i+1),
        C  => clk,
        CE => '1',
        D  => a_ddr(i),
        R  => rst,
        S  => '0');

    Channel_B_IDDR_inst : IDDR
      generic map (
        DDR_CLK_EDGE => "OPPOSITE_EDGE",
        INIT_Q1      => '0',
        INIT_Q2      => '0',
        SRTYPE       => "ASYNC")
      port map (
        Q1 => dout_b(2*i),
        Q2 => dout_b(2*i+1),
        C  => clk,
        CE => '1',
        D  => b_ddr(i),
        R  => rst,
        S  => '0');
  end generate ADC_Data;

end Behavioral;
