------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/04/24 16:34:06
-- Design Name: 
-- Module Name: oneshot_pulse - Behavioral
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
------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity oneshot_pulse is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    d   : in  std_logic;
    q   : out std_logic);
end entity oneshot_pulse;

architecture Behavioral of oneshot_pulse is

  signal d_buf : std_logic;
  
begin

  process(clk)
  begin
    if (clk'event and clk = '1') then
      if rst = '1' then
        d_buf <= '0';
      else
        d_buf <= d;
      end if;
    end if;
  end process;

  q <= d and (not d_buf);

end Behavioral;
