-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/06/01 16:03:36
-- Design Name: 
-- Module Name: timing_buffer - Behavioral
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

entity timing_buffer is
  port (
    clk     : in std_logic;
    adc_rst : in std_logic);
end entity timing_buffer;

architecture Behavioral of timing_buffer is

  signal adc_rst_buf : std_logic;
  
begin
  
  process(clk)
  begin
    if rising_edge(clk) then
      
    end if;
  end process;

end architecture Behavioral;
