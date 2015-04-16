-----------------------------------------------------------------------------
-- Company: 
-- Engineer: ISHITSUKA Hikaru
-- 
-- Create Date: 2014/11/21 15:05:57
-- Design Name: 
-- Module Name: rs_ff - Behavioral
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
-- arithmetic functions with signed or Unsigned values
--use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rs_ff is
  port (
    r  : in  std_logic;
    s  : in  std_logic;
    q  : out std_logic;
    qb : out std_logic);
end rs_ff;

architecture behavioral of rs_ff is

  signal q_buf  : std_logic;
  signal qb_buf : std_logic;

begin

  q_buf  <= r nor qb_buf;
  qb_buf <= s nor q_buf;
  q      <= q_buf;
  qb     <= qb_buf;

end behavioral;
