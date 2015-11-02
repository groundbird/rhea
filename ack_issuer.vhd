-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/10/22 17:28:08
-- Design Name: 
-- Module Name: ack_issuer - Behavioral
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

entity ack_issuer is
  generic (
    delay : integer := 0);
  port (
    clk     : in     std_logic;
    rst     : in     std_logic;
    req     : in     std_logic;
    busy    : out    std_logic;
    ack     : buffer std_logic;
    ack_cnt : buffer std_logic_vector(7 downto 0));
end ack_issuer;

architecture Behavioral of ack_issuer is

  type state_type is (s0, s1, s2);
  signal state : state_type;
  
begin  -- architecture Behavioral

  busy <= '1' when state /= s0 else '0';
  ack  <= '1' when state = s2  else '0';

  process(clk)
    variable cnt : integer := 0;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        cnt   := 0;
        state <= s0;
      else
        case state is
          when s0 =>
            if req = '1' then
              state <= s1;
            else
              state <= s0;
            end if;

          when s1 =>
            if cnt = delay then
              state <= s2;
            else
              cnt   := cnt + 1;
              state <= s1;
            end if;

          when s2 => state <= s0;

          when others => null;
        end case;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        ack_cnt <= (others => '0');
      else
        ack_cnt <= ack_cnt + ack;
      end if;
    end if;
  end process;

end architecture Behavioral;
