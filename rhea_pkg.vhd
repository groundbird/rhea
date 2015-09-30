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

  ---------------------------------------------------------------------------
  -- Global Constants
  ---------------------------------------------------------------------------
  constant N_CHANNEL       : integer := 1;
  constant DOWNSAMPLE_RATE : integer := 200000;
  constant IQ_DATA_WIDTH   : integer := 56;
  constant LATENCY_ACC     : integer := 5;   -- accumlator latency

  ---------------------------------------------------------------------------
  -- User-difined Data Type
  ---------------------------------------------------------------------------
  subtype byte is std_logic_vector(7 downto 0);
  type byte_array is array (natural range <>) of byte;

  subtype iq_bus is std_logic_vector(IQ_DATA_WIDTH-1 downto 0);
  type iq_array is array (N_CHANNEL-1 downto 0) of iq_bus;
  
end rhea_pkg;
