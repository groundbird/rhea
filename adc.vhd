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
    clk     : in  std_logic;
    rst     : in  std_logic;
    cha_p   : in  std_logic_vector(6 downto 0);
    cha_n   : in  std_logic_vector(6 downto 0);
    chb_p   : in  std_logic_vector(6 downto 0);
    chb_n   : in  std_logic_vector(6 downto 0);
    adc_cha : out std_logic_vector(13 downto 0);
    adc_chb : out std_logic_vector(13 downto 0));
end adc;

architecture Behavioral of adc is

  signal cha_ddr : std_logic_vector(6 downto 0);
  signal chb_ddr : std_logic_vector(6 downto 0);

begin

  ADC_Data : for i in 0 to 6 generate
    IBUFDS_inst : IBUFDS
      generic map (
        DIFF_TERM    => false,
        IBUF_LOW_PWR => true,
        IOSTANDARD   => "DEFAULT")
      port map (
        O  => cha_ddr(i),
        I  => cha_p(i),
        IB => cha_n(i));

    ISERDESE2_inst : ISERDESE2
      generic map (
        DATA_RATE         => "DDR",
        DATA_WIDTH        => 2,
        DYN_CLKDIV_INV_EN => "FALSE",
        DYN_CLK_INV_EN    => "FALSE",
        INIT_Q1           => '0',
        INIT_Q2           => '0',
        INIT_Q3           => '0',
        INIT_Q4           => '0',
        INTERFACE_TYPE    => "MEMORY",
        IOBDELAY          => "NONE",
        NUM_CE            => 1,
        OFB_USED          => "FALSE",
        SERDES_MODE       => "MASTER",
        SRVAL_Q1          => '0',
        SRVAL_Q2          => '0',
        SRVAL_Q3          => '0',
        SRVAL_Q4          => '0')
      port map (
        O         => open,
        Q1        => adc_cha(2*i + 1),
        Q2        => adc_cha(2*i),
        Q3        => open,
        Q4        => open,
        Q5        => open,
        Q6        => open,
        Q7        => open,
        Q8        => open,
        SHIFTOUT1 => open,
        SHIFTOUT2 => open,
        BITSLIP   => '0',
        CE1          => '1',
        CE2          => '0',
        CLKDIVP      => '0',
        CLK          => clk,
        CLKB         => '0',
        CLKDIV       => clk_div,
        OCLK         => '0',
        DYNCLKDIVSEL => '0',
        DYNCLKSEL    => '0',
        D            => '0',
        DDLY         => '0',
        OFB          => '0',
        OCLKB        => '0',
        RST          => rst,
        SHIFTIN1     => '0',
        SHIFTIN2     => '0');

--    IBUFDS_inst : IBUFDS
--      generic map (
--        DIFF_TERM    => false,
--        IBUF_LOW_PWR => true,
--        IOSTANDARD   => "DEFAULT")
--      port map (
--        O  => chb_ddr(i),
--        I  => chb_p(i),
--        IB => chb_n(i));
  end generate;


end Behavioral;
