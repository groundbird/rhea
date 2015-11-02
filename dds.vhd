-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/06/05 10:27:26
-- Design Name: 
-- Module Name: dds - Behavioral
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

entity dds is
  port (
    clk      : in     std_logic;
    rst      : in     std_logic;
    en       : in     std_logic;
    pinc     : in     std_logic_vector(31 downto 0);
    pinc_reg : buffer std_logic_vector(31 downto 0);
    valid    : out    std_logic;
--    cos      : out    std_logic_vector(15 downto 0);
--    sin      : out    std_logic_vector(15 downto 0);
    cos      : out    std_logic_vector(SIN_COS_WIDTH-1 downto 0);
    sin      : out    std_logic_vector(SIN_COS_WIDTH-1 downto 0);
    busy     : out    std_logic;
    ack      : out    std_logic);
end entity dds;

architecture Behavioral of dds is

  component dds_compiler is
    port (
      aclk                : in  std_logic;
      aclken              : in  std_logic;
      aresetn             : in  std_logic;
      s_axis_phase_tvalid : in  std_logic;
      s_axis_phase_tdata  : in  std_logic_vector(31 downto 0);
      m_axis_data_tvalid  : out std_logic;
      m_axis_data_tdata   : out std_logic_vector(31 downto 0));
  end component dds_compiler;

  signal dds_rstn : std_logic;
  signal dds_data : std_logic_vector(31 downto 0);

  type dds_state is (idle, init, exec, fini);
  signal s_dds : dds_state;

begin

  Timing_Buffer_proc : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        sin <= (others => '0');
        cos <= (others => '0');
      else
--        sin <= dds_data(31 downto 16);
--        cos <= dds_data(15 downto 0);
        sin <= dds_data(SIN_COS_WIDTH+15 downto 16);
        cos <= dds_data(SIN_COS_WIDTH-1 downto 0);
      end if;
    end if;
  end process;

  DDS_Compiler_inst : dds_compiler
    port map (
      -- in
      aclk                => clk,
      aclken              => "not"(rst),
      aresetn             => dds_rstn,
      s_axis_phase_tvalid => "not"(rst),
      s_axis_phase_tdata  => pinc_reg,
      -- out
      m_axis_data_tvalid  => valid,
      m_axis_data_tdata   => dds_data);

  busy     <= '1' when s_dds /= idle else '0';
  dds_rstn <= '0' when s_dds = init  else '1';
  ack      <= '1' when s_dds = fini  else '0';

  DDS_SM : process(clk)
    variable cnt : integer range 0 to 9 := 0;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        pinc_reg <= (others => '0');
        cnt      := 0;
        s_dds    <= idle;
      else
        case s_dds is
          when idle =>
            if en = '1' then
              cnt   := 0;
              s_dds <= init;
            else
              s_dds <= idle;
            end if;

          when init =>
            if cnt = 1 then
              pinc_reg <= pinc;
              cnt      := 0;
              s_dds    <= exec;
            else
              cnt   := cnt + 1;
              s_dds <= init;
            end if;

          when exec =>
            if cnt = 9 then
              -- Rising DDS valid takes 9 clock after the DDS reset.
              s_dds <= fini;
            else
              cnt   := cnt + 1;
              s_dds <= exec;
            end if;

          when fini => s_dds <= idle;

          when others => s_dds <= idle;
        end case;
      end if;
    end if;
  end process;

end architecture Behavioral;
