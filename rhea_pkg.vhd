-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/04/01 22:47:57
-- Design Name: 
-- Module Name: rhea_pkg - Behavioral
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

package rhea_pkg is

  -- timestamp size
--  constant ts_size : integer := 5;      -- bytes

  -- "d_size" is the main data of formated data (i.e., compose of header,
  -- timestamp, main data and footer).
  constant d_size : integer := 4;
--  constant adc_ss_d_size : integer := 4;  -- bytes
  -- header (1) + timestamp (5) + data + footer (1); (bytes)
--  constant fmt_data_size : integer := d_size+7;
--  constant fmt_data_size : integer := 1024*100;  -- bytes
--  type fmt_data is array(natural range <>) of std_logic_vector(7 downto 0);

  -- ADC Snapshot
--  constant adc_ss_d_cnt : integer := 100;  -- snapshot size [KB]

  -- raw data size of formated data
--  constant raw_data_size : integer := fmt_data_size-ts_size-2;  -- 1017 bytes

  subtype byte is std_logic_vector(7 downto 0);
  type byte_array is array(natural range <>) of byte;
  
end rhea_pkg;
