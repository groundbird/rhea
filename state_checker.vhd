-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/09/09 23:01:01
-- Design Name: 
-- Module Name: state_checker - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity state_checker is
  port (
    clk  : in    std_logic;
    rst  : in    std_logic;
    req  : in    std_logic;
    ack  : out   std_logic);
end entity state_checker;

architecture Behavioral of state_checker is

  type main_state is (idle, exec);
  signal s_main : main_state;

begin

  ack <= '1' when s_main = exec else '0';

  Main_SM_proc : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        s_main <= idle;
      else
        case s_main is
          when idle =>
            if req = '1' then
              s_main <= exec;
            else
              s_main <= idle;
            end if;

          when exec => s_main <= idle;
              
        when others => null;
      end case;
    end if;
  end if;
end process;

end architecture Behavioral;
