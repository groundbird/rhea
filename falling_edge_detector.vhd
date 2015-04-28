-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/04/24 17:22:41
-- Design Name: 
-- Module Name: falling_edge_detector - Behavioral
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
--library UNISIM;
--use UNISIM.VComponents.all;

entity falling_edge_detector is
  port (
    clk : in  std_logic;
    d   : in  std_logic;
    q   : out std_logic);
end entity falling_edge_detector;

architecture Behavioral of falling_edge_detector is

  signal d_buf : std_logic;

begin

  process(clk)
  begin
    if (clk'event and clk = '1') then
      d_buf <= d;
    end if;
  end process;

  q <= (not d) and d_buf;

end architecture Behavioral;
