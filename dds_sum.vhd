-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/09/30 23:04:02
-- Design Name: 
-- Module Name: dds_sum - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

library work;
use work.rhea_pkg.all;

entity dds_sum is
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    dds_cos : in  dds_data_array;
    dds_sin : in  dds_data_array;
    dac_cos : out std_logic_vector(15 downto 0);
    dac_sin : out std_logic_vector(15 downto 0));
end dds_sum;

architecture Behavioral of dds_sum is

  component dds_adder is
    port (
      a   : in  std_logic_vector(15 downto 0);
      b   : in  std_logic_vector(15 downto 0);
      clk : in  std_logic;
      s   : out std_logic_vector(16 downto 0));
  end component dds_adder;

  signal dds_cos_buf : std_logic_vector(16 downto 0);
  signal dds_sin_buf : std_logic_vector(16 downto 0);

--  signal dac_cos_buf : std_logic_vector(14 downto 0);
--  signal dac_sin_buf : std_logic_vector(14 downto 0);

begin

--  dac_cos <= dds_cos(0);
--  dac_sin <= dds_sin(0);
--  process(clk)
--  begin
--    if rising_edge(clk) then
--      dac_cos_buf <= dds_cos(0)(15 downto 1);
--      dac_sin_buf <= dds_sin(0)(15 downto 1);

--      dac_cos <= conv_std_logic_vector(signed(dac_cos_buf), 16);
--      dac_sin <= conv_std_logic_vector(signed(dac_sin_buf), 16);
--    end if;
--  end process;

--  dac_cos <= conv_std_logic_vector(signed(dds_cos_buf(16 downto 2)), 16);
--  dac_sin <= conv_std_logic_vector(signed(dds_sin_buf(16 downto 2)), 16);

  dac_cos <= dds_cos_buf(16 downto 1);
  dac_sin <= dds_sin_buf(16 downto 1);

  add_pairs_for_2ch : for i in 0 to N_CHANNEL/2-1 generate
    dds_adder_cos_2ch_inst : dds_adder
      port map (
        a   => dds_cos(2*i),
        b   => dds_cos(2*i+1),
        clk => clk,
        s   => dds_cos_buf);
    dds_adder_sin_2ch_inst : dds_adder
      port map (
        a   => dds_sin(2*i),
        b   => dds_sin(2*i+1),
        clk => clk,
        s   => dds_sin_buf);
  end generate;

--  add_pairs_for_4ch : for i in 0 to N_CHANNEL/4-1 generate
--    dds_adder_cos_4ch_inst : dds_adder
--      port map (
--        a   => dds_cos_buf(2*i),
--        b   => dds_cos_buf(2*i+1),
--        clk => clk,
--        s   => dds_cos_bbuf(i));
--    dds_adder_sin_4ch_inst : dds_adder
--      port map (
--        a   => dds_sin_buf(2*i),
--        b   => dds_sin_buf(2*i+1),
--        clk => clk,
--        s   => dds_sin_bbuf(i));
--  end generate;

end architecture Behavioral;
