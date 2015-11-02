-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/10/22 15:18:23
-- Design Name: 
-- Module Name: dds_prop - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: This module is DDS property (e.g., phase increment,
--      phase offset) register from RBCP module.
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

entity dds_prop is
  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
    en           : in  std_logic;
    dds_pinc_tmp : in  dds_pinc_array;
    dds_pinc     : out dds_pinc_array;
    busy         : out std_logic;
    ack          : out std_logic);
end dds_prop;

architecture Behavioral of dds_prop is

  type dds_prop_state is (idle, reg, fini);
  signal s_dds_prop : dds_prop_state;
  
begin  -- architecture Behavioral

  busy <= '1' when s_dds_prop /= idle else '0';
  ack  <= '1' when s_dds_prop = fini  else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        s_dds_prop <= idle;
        dds_pinc   <= (others => x"00000000");
      else
        case s_dds_prop is
          when idle =>
            if en = '1' then
              s_dds_prop <= reg;
            else
              s_dds_prop <= idle;
            end if;

          when reg =>
            dds_pinc   <= dds_pinc_tmp;
            s_dds_prop <= fini;

          when fini => s_dds_prop <= idle;

          when others => null;
        end case;
      end if;
    end if;
  end process;

end architecture Behavioral;
