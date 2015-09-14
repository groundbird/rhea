-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/04/24 19:24:20
-- Design Name: 
-- Module Name: adc_snapshot - Behavioral
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

entity adc_snapshot is
  port (
    clk           : in     std_logic;
    rst           : in     std_logic;
    en            : in     std_logic;
    fmt_busy      : in     std_logic;
    din_a         : in     std_logic_vector(13 downto 0);
    din_b         : in     std_logic_vector(13 downto 0);
    wr_data_count : in     std_logic_vector(16 downto 0);
    dout          : out    byte_array(3 downto 0);
    valid         : buffer std_logic;
    ack           : out    std_logic);
end entity adc_snapshot;

architecture Behavioral of adc_snapshot is

  type fifo_state is (idle, init, exec, fini);
  signal s_fifo : fifo_state;

  signal din_a_buf : std_logic_vector(15 downto 0);
  signal din_b_buf : std_logic_vector(15 downto 0);
  signal cnt       : std_logic_vector(16 downto 0);

  component fifo_for_adc_snapshot is
    port (
      clk         : in  std_logic;
      rst         : in  std_logic;
      din         : in  std_logic_vector(31 downto 0);
      wr_en       : in  std_logic;
      rd_en       : in  std_logic;
      dout        : out std_logic_vector(31 downto 0);
      full        : out std_logic;
      almost_full : out std_logic;
      empty       : out std_logic);
  end component fifo_for_adc_snapshot;

--  component fifo_for_adc_snapshot is
--    port (
--      clk         : in  std_logic;
--      srst        : in  std_logic;
--      din         : in  std_logic_vector(31 downto 0);
--      wr_en       : in  std_logic;
--      rd_en       : in  std_logic;
--      dout        : out std_logic_vector(31 downto 0);
--      full        : out std_logic;
--      empty       : out std_logic;
--      wr_rst_busy : out std_logic;
--      rd_rst_busy : out std_logic);
--  end component fifo_for_adc_snapshot;

  signal fifo_rst    : std_logic;
  signal din         : std_logic_vector(31 downto 0);
  signal wr_en       : std_logic;
  signal dout_buf    : std_logic_vector(31 downto 0);
  signal full        : std_logic;
  signal almost_full : std_logic;
  signal empty       : std_logic;

begin

  Timing_Buffer_proc : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        din_a_buf <= (others => '0');
        din_b_buf <= (others => '0');
        din       <= (others => '0');
      else
        din_a_buf <= conv_std_logic_vector(signed(din_a), 16);
        din_b_buf <= conv_std_logic_vector(signed(din_b), 16);
        din       <= din_a_buf & din_b_buf;
      end if;
    end if;
  end process;

--  din <= din_a_buf & din_b_buf;

  Format_ADC_Data_gen : for i in 0 to 3 generate
    dout(3-i) <= dout_buf(8*i+7 downto 8*i);
  end generate Format_ADC_Data_gen;

  FIFO_512KB_for_ADC_Snapshot : fifo_for_adc_snapshot
    port map (
      clk         => clk,
      rst         => fifo_rst,
      din         => din,
      wr_en       => wr_en,
      rd_en       => valid,
      dout        => dout_buf,
      full        => full,
      almost_full => almost_full,
      empty       => empty);

--  FIFO_512KB_for_ADC_Snapshot : fifo_for_adc_snapshot
--    port map (
--      clk         => clk,
--      srst        => fifo_rst,
--      din         => din,
--      wr_en       => wr_en,
--      rd_en       => valid,
--      dout        => dout_buf,
--      full        => full,
--      empty       => empty,
--      wr_rst_busy => open,
--      rd_rst_busy => open);

  wr_en <= '1' when s_fifo = exec else '0';
  ack   <= '1' when s_fifo = fini else '0';
  valid <= not (fmt_busy or empty or wr_data_count(16));

  FIFO_512KB_SM : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        fifo_rst <= '1';
        s_fifo   <= idle;
        cnt      <= (others => '0');
      else
        case s_fifo is
          when idle =>
            if en = '1' then
              fifo_rst <= '1';
              s_fifo   <= init;
            else
              s_fifo <= idle;
            end if;

          when init =>
            fifo_rst <= '0';
            if full = '0' and empty = '1' then
              s_fifo <= exec;
            else
              cnt    <= (others => '0');
              s_fifo <= init;
            end if;

          when exec =>
            if cnt = (cnt'range => '1') then
              s_fifo <= fini;
            else
              cnt    <= cnt + 1;
              s_fifo <= exec;
            end if;

          when fini => s_fifo <= idle;

          when others => null;
        end case;
      end if;
    end if;
  end process;

end architecture Behavioral;
