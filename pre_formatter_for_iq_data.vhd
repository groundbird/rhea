-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/07/02 17:11:05
-- Design Name: 
-- Module Name: pre_formatter_for_iq_data - Behavioral
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

entity pre_formatter_for_iq_data is
  
  port (
    clk : in std_logic;
    rst : in std_logic;
    iq_data : in std_logic);

end entity pre_formatter_for_iq_data;



Convert_iqarray_to_byte_array : for i in 0 to N_CHANNEL-1 generate
    Serialize_IQ_Data : for j in 0 to IQ_DATA_WIDTH/8-1 generate
      fmt_iq_data(IQ_DATA_WIDTH/4*i + j)                 <= i_data_ds(i)(8*j+7 downto 8*j);
      fmt_iq_data(IQ_DATA_WIDTH/4*i + j+IQ_DATA_WIDTH/8) <= q_data_ds(i)(8*j+7 downto 8*j);
    end generate Serialize_IQ_Data;
  end generate Convert_iqarray_to_byte_array;
