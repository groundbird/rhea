-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/04/20 15:51:03
-- Design Name: 
-- Module Name: timestamp - Behavioral
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

entity timestamp is
  generic (
    ts_size : integer);                 -- bytes
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    trg : in  std_logic;
    ts  : out byte_array(ts_size-1 downto 0));
end entity timestamp;

architecture Behavioral of timestamp is

  signal ts_buf : std_logic_vector(ts_size*8-1 downto 0);

begin

  Timestamp_gen : for i in 0 to ts_size-1 generate
    ts(ts_size-1 - i) <= ts_buf(7+8*i downto 8*i);
  end generate Timestamp_gen;

  process(rst, clk)
  begin
    if rst = '1' then
      ts_buf <= (others => '0');
    elsif (clk'event and clk = '1') then
      ts_buf <= ts_buf + trg;
    else
      null;
    end if;
  end process;

end architecture Behavioral;
