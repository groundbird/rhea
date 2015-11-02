-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/06/15 15:46:50
-- Design Name: 
-- Module Name: iq_reader - Behavioral
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

entity iq_reader is
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    req      : in  std_logic;
--    tgl      : in  std_logic;
    fmt_busy : in  std_logic;
    valid    : out std_logic;
    busy     : out std_logic;
    ack      : out std_logic);
end entity iq_reader;

architecture Behavioral of iq_reader is

  type iq_state is (idle, init, exec, fini);
  signal s_iq : iq_state;

begin

  valid <= '1' when s_iq = exec                else '0';
  ack   <= '1' when s_iq = init or s_iq = fini else '0';
  busy  <= '1' when s_iq /= idle               else '0';

  IQ_Reader_SM : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        s_iq <= idle;
      else
        case s_iq is
          when idle =>
            if req = '1' and fmt_busy = '0' then
              s_iq <= init;
            else
              s_iq <= idle;
            end if;

          when init => s_iq <= exec;

          when exec =>
            if req = '1' then
              s_iq <= fini;
            else
              s_iq <= exec;
            end if;

          when fini => s_iq <= idle;

          when others => s_iq <= idle;
        end case;
      end if;
    end if;
  end process;

end architecture Behavioral;
