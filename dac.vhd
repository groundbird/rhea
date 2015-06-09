-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/06/08 18:54:00
-- Design Name: 
-- Module Name: dac - Behavioral
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
library UNISIM;
use UNISIM.VComponents.all;

entity dac is
  port (
    clk     : in  std_logic;
    clk_2x  : in  std_logic;
    rst     : in  std_logic;
    -- DAC I/O
    din_a   : in  std_logic_vector(15 downto 0);
    din_b   : in  std_logic_vector(15 downto 0);
    dclk_p  : out std_logic;
    dclk_n  : out std_logic;
    frame_p : out std_logic;
    frame_n : out std_logic;
    dout_p  : out std_logic_vector(7 downto 0);
    dout_n  : out std_logic_vector(7 downto 0));
end entity dac;

architecture behavioral of dac is

  signal frame : std_logic;
  signal data  : std_logic_vector(7 downto 0);

begin

  DAC_Data_Clock : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT",
      SLEW       => "SLOW")
    port map (
      O  => dclk_p,
      OB => dclk_n,
      I  => "not"(clk));

  DAC_Frame : OBUFDS
    generic map (
      IOSTANDARD => "DEFAULT",
      SLEW       => "SLOW")
    port map (
      O  => frame_p,
      OB => frame_n,
      I  => frame);

  DAC_Data : for i in 0 to 7 generate
    DAC_Data_OSERDES2_inst : OSERDESE2
      generic map (
        DATA_RATE_OQ   => "DDR",
        DATA_RATE_TQ   => "DDR",
        DATA_WIDTH     => 4,
        INIT_OQ        => '0',
        INIT_TQ        => '0',
        SERDES_MODE    => "MASTER",
        SRVAL_OQ       => '0',
        SRVAL_TQ       => '0',
        TBYTE_CTL      => "FALSE",
        TBYTE_SRC      => "FALSE",
        TRISTATE_WIDTH => 1)
      port map (
        OFB       => open,
        OQ        => data(i),
        SHIFTOUT1 => open,
        SHIFTOUT2 => open,
        TBYTEOUT  => open,
        TFB       => open,
        TQ        => open,
        CLK       => clk_2x,
        CLKDIV    => clk,
        D1        => din_a(i+8),
        D2        => din_a(i),
        D3        => din_b(i+8),
        D4        => din_b(i),
        D5        => '0',
        D6        => '0',
        D7        => '0',
        D8        => '0',
        OCE       => '1',
--        RST       => "not"(rst),
        RST       => rst,
        SHIFTIN1  => '0',
        SHIFTIN2  => '0',
        T1        => '0',
        T2        => '0',
        T3        => '0',
        T4        => '0',
        TBYTEIN   => '0',
        TCE       => '0');

    DAC_Data_OBUFDS_inst : OBUFDS
      generic map (
        IOSTANDARD => "DEFAULT",
        SLEW       => "SLOW")
      port map (
        O  => dout_p(i),
        OB => dout_n(i),
        I  => data(i));
  end generate DAC_Data;

  Frame_proc : process(clk)
    variable cnt : integer range 0 to 15;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        cnt   := 0;
        frame <= '0';
      else
        if cnt = 15 then
          frame <= '1';
          cnt   := 0;
        else
          frame <= '0';
          cnt   := cnt + 1;
        end if;
      end if;
    end if;
  end process;

end Behavioral;
