-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/06/11 15:35:30
-- Design Name: 
-- Module Name: ddc_sim - Behavioral
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
--use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

library work;
use work.rhea_pkg.all;

entity ddc_sim is
end entity ddc_sim;

architecture Behavioral of ddc_sim is

  constant clk_period : time := 5 ns;   -- 200 MHz

  component dac is
    port (
      clk      : in  std_logic;
      clk_2x   : in  std_logic;
      rst      : in  std_logic;
      din_a    : in  std_logic_vector(15 downto 0);
      din_b    : in  std_logic_vector(15 downto 0);
      dclk_p   : out std_logic;
      dclk_n   : out std_logic;
      frame_p  : out std_logic;
      frame_n  : out std_logic;
      dout_p   : out std_logic_vector(7 downto 0);
      dout_n   : out std_logic_vector(7 downto 0);
      txenable : out std_logic);
  end component dac;

  signal clk_2x   : std_logic;
  signal clk_div  : std_logic;
  signal dclk_p   : std_logic;
  signal dclk_n   : std_logic;
  signal frame_p  : std_logic;
  signal frame_n  : std_logic;
  signal dout_p   : std_logic_vector(7 downto 0);
  signal dout_n   : std_logic_vector(7 downto 0);
  signal txenable : std_logic;

  component dds is
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      en    : in  std_logic;
      pinc  : in  std_logic_vector(31 downto 0);
      valid : out std_logic;
      cos   : out std_logic_vector(15 downto 0);
      sin   : out std_logic_vector(15 downto 0);
      busy  : out std_logic;
      ack   : out std_logic);
  end component dds;

  signal clk       : std_logic;
  signal rst       : std_logic;
  signal dds_en    : std_logic;
  signal pinc      : std_logic_vector(31 downto 0);
  signal dds_valid : std_logic;
  signal cos       : std_logic_vector(15 downto 0);
  signal sin       : std_logic_vector(15 downto 0);
  signal busy      : std_logic;
  signal ack       : std_logic;

  component ddc is
    port (
      clk    : in  std_logic;
      rst    : in  std_logic;
      adcd_a : in  std_logic_vector(15 downto 0);
      adcd_b : in  std_logic_vector(15 downto 0);
      cos    : in  std_logic_vector(15 downto 0);
      sin    : in  std_logic_vector(15 downto 0);
      iout   : out std_logic_vector(31 downto 0);
      qout   : out std_logic_vector(31 downto 0));
  end component ddc;

  signal iarray : std_logic_vector(31 downto 0);
  signal qarray : std_logic_vector(31 downto 0);

begin

  ---------------------------------------------------------------------------
  -- DAC
  ---------------------------------------------------------------------------
  DAC_inst : dac
    port map (
      clk      => clk,
      clk_2x   => clk_2x,
      rst      => rst or dds_en,
      din_a    => cos,
      din_b    => sin,
      dclk_p   => dclk_p,
      dclk_n   => dclk_n,
      frame_p  => frame_p,
      frame_n  => frame_n,
      dout_p   => dout_p,
      dout_n   => dout_n,
      txenable => txenable);

  ---------------------------------------------------------------------------
  -- DDS
  ---------------------------------------------------------------------------
  DDS_inst : dds
    port map (
      clk   => clk,
      rst   => rst,
      en    => dds_en,
      pinc  => pinc,
      valid => dds_valid,
      cos   => cos,
      sin   => sin,
      busy  => busy,
      ack   => ack);

  ---------------------------------------------------------------------------
  -- DDC
  ---------------------------------------------------------------------------
  DDC_inst : ddc
    port map (
      clk    => clk,
      rst    => rst,
      adcd_a => cos,
      adcd_b => sin,
      cos    => cos,
      sin    => sin,
      iout   => iarray,
      qout   => qarray);

  ---------------------------------------------------------------------------
  -- Clock
  ---------------------------------------------------------------------------
  Sys_CLK_proc : process
  begin
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
  end process;

  Sys_CLK_2x_proc : process
  begin
    clk_2x <= '1';
    wait for clk_period/4;
    clk_2x <= '0';
    wait for clk_period/4;
  end process;

  Sys_CLK_div_proc : process
  begin
    clk_div <= '1';
    wait for clk_period;
    clk_div <= '0';
    wait for clk_period;
  end process;

  ---------------------------------------------------------------------------
  -- Stimulus Process (Main)
  ---------------------------------------------------------------------------
  stim_proc : process
  begin

    -- init.
    rst    <= '1';
    dds_en <= '0';
    pinc   <= (others => '0');

    wait for clk_period*3;
    rst <= '0';

    wait for clk_period*10;

    dds_en <= '1';
--    pinc   <= conv_std_logic_vector(536870912, 32);  -- fout = 25 MHz
    pinc   <= conv_std_logic_vector(1073741824, 32);  -- fout = 50 MHz
--    pinc   <= conv_std_logic_vector(21474, 32);  -- fout = 1 kHz
    wait for clk_period;
    dds_en <= '0';

    wait for clk_period*100;

    dds_en <= '1';
    pinc   <= conv_std_logic_vector(214748364, 32);  -- fout = 10 MHz
    wait for clk_period;
    dds_en <= '0';

    wait for clk_period*100;

    dds_en <= '1';
    pinc   <= conv_std_logic_vector(536870912, 32);  -- fout = 25 MHz
    wait for clk_period;
    dds_en <= '0';

    wait;
  end process;
  
end Behavioral;
