-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/06/11 13:16:18
-- Design Name: 
-- Module Name: ddc - Behavioral
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

entity ddc is
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    adcd_a : in  std_logic_vector(13 downto 0);
    adcd_b : in  std_logic_vector(13 downto 0);
    cos    : in  std_logic_vector(15 downto 0);
    sin    : in  std_logic_vector(15 downto 0);
    iout   : out std_logic_vector(30 downto 0);
    qout   : out std_logic_vector(30 downto 0));
end entity ddc;

architecture Behavioral of ddc is

  component multiplier is
    port (
      clk : in  std_logic;
      a   : in  std_logic_vector(13 downto 0);
      b   : in  std_logic_vector(15 downto 0);
      p   : out std_logic_vector(29 downto 0));
  end component multiplier;

  signal adcd_a_buf : std_logic_vector(13 downto 0);
  signal adcd_b_buf : std_logic_vector(13 downto 0);
  signal cos_buf    : std_logic_vector(15 downto 0);
  signal sin_buf    : std_logic_vector(15 downto 0);

  signal coscos : std_logic_vector(29 downto 0);
  signal sinsin : std_logic_vector(29 downto 0);
  signal sincos : std_logic_vector(29 downto 0);
  signal cossin : std_logic_vector(29 downto 0);

  signal coscos_buf : std_logic_vector(29 downto 0);
  signal sinsin_buf : std_logic_vector(29 downto 0);
  signal sincos_buf : std_logic_vector(29 downto 0);
  signal cossin_buf : std_logic_vector(29 downto 0);

  component adder is
    port (
      a   : in  std_logic_vector(29 downto 0);
      b   : in  std_logic_vector(29 downto 0);
      clk : in  std_logic;
      s   : out std_logic_vector(30 downto 0));      
  end component adder;

  signal iout_buf : std_logic_vector(30 downto 0);

  component subtracter is
    port (
      a   : in  std_logic_vector(29 downto 0);
      b   : in  std_logic_vector(29 downto 0);
      clk : in  std_logic;
      s   : out std_logic_vector(30 downto 0));
  end component subtracter;

  signal qout_buf : std_logic_vector(30 downto 0);

begin

  Timing_Buffer_proc : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        adcd_a_buf <= (others => '0');
        adcd_b_buf <= (others => '0');
        cos_buf    <= (others => '0');
        sin_buf    <= (others => '0');
        coscos_buf <= (others => '0');
        sinsin_buf <= (others => '0');
        sincos_buf <= (others => '0');
        cossin_buf <= (others => '0');
        iout       <= (others => '0');
        qout       <= (others => '0');
      else
        adcd_a_buf <= adcd_a;
        adcd_b_buf <= adcd_b;
        cos_buf    <= cos;
        sin_buf    <= sin;
        coscos_buf <= coscos;
        sinsin_buf <= sinsin;
        sincos_buf <= sincos;
        cossin_buf <= cossin;
        iout       <= iout_buf;
        qout       <= qout_buf;
      end if;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- Multiplier
  ---------------------------------------------------------------------------
  CosCos_Multiplier_inst : multiplier
    port map (
      clk => clk,
      a   => adcd_a_buf,
      b   => cos_buf,
      p   => coscos);

  SinSin_Multiplier_inst : multiplier
    port map (
      clk => clk,
      a   => adcd_b_buf,
      b   => sin_buf,
      p   => sinsin);

  CosSin_Multiplier_inst : multiplier
    port map (
      clk => clk,
      a   => adcd_a_buf,
      b   => sin_buf,
      p   => cossin);

  SinCos_Multiplier_inst : multiplier
    port map (
      clk => clk,
      a   => adcd_b_buf,
      b   => cos_buf,
      p   => sincos);

  ---------------------------------------------------------------------------
  -- Adder/Substracter
  ---------------------------------------------------------------------------
  CosCos_SinSin_Adder_inst : adder
    port map (
      a   => coscos_buf,
      b   => sinsin_buf,
      clk => clk,
      s   => iout_buf);

  SinCos_CosSin_Substracter_inst : subtracter
    port map (
      a   => sincos_buf,
      b   => cossin_buf,
      clk => clk,
      s   => qout_buf);

end architecture Behavioral;
