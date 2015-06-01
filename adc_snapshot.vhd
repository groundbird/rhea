-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015-04-24 19:24:20
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
    clk        : in     std_logic;
    rst        : in     std_logic;
    en         : in     std_logic;
    fmt_busy   : in     std_logic;
    adc_data_a : in     std_logic_vector(13 downto 0);
    adc_data_b : in     std_logic_vector(13 downto 0);
    dout       : out    byte_array(3 downto 0);
    rd_en      : buffer std_logic;
    ack        : out    std_logic);
end entity adc_snapshot;

architecture Behavioral of adc_snapshot is

  type fifo_state is (idle, init, exec, fini);
--  type fifo_state is (idle, init, wr, rd, fini);
  signal s_fifo : fifo_state;

  signal adcda_fmt : std_logic_vector(15 downto 0);
  signal adcdb_fmt : std_logic_vector(15 downto 0);

  component fifo_adc_snapshot is
    port (
      clk         : in  std_logic;
      srst        : in  std_logic;
      din         : in  std_logic_vector(31 downto 0);
      wr_en       : in  std_logic;
      rd_en       : in  std_logic;
      dout        : out std_logic_vector(31 downto 0);
      full        : out std_logic;
      almost_full : out std_logic;
      empty       : out std_logic;
--      data_count  : out std_logic_vector(16 downto 0));
      data_count  : out std_logic_vector(7 downto 0));
  end component fifo_adc_snapshot;

  signal fifo_rst    : std_logic;
  signal din         : std_logic_vector(31 downto 0);
  signal wr_en       : std_logic;
  signal dout_buf    : std_logic_vector(31 downto 0);
  signal full        : std_logic;
  signal almost_full : std_logic;
  signal empty       : std_logic;
--  signal data_count  : std_logic_vector(16 downto 0);
  signal data_count  : std_logic_vector(7 downto 0);

  signal cnt : std_logic_vector(data_count'left downto 0);
  
begin

  adcda_fmt <= "00" & adc_data_a;
  adcdb_fmt <= "00" & adc_data_b;
--  din       <= adcda_fmt & adcdb_fmt when s_fifo = wr else (others => '0');
  din       <= adcda_fmt & adcdb_fmt;

  Format_ADC_Data_gen : for i in 0 to 3 generate
    dout(3-i) <= dout_buf(8*i+7 downto 8*i);
  end generate Format_ADC_Data_gen;

  FIFO_512KB_for_ADC_Snapshot : fifo_adc_snapshot
    port map (
      clk         => clk,
      srst        => fifo_rst,
      din         => din,
      wr_en       => wr_en,
      rd_en       => rd_en,
      dout        => dout_buf,
      full        => full,
      almost_full => almost_full,
      empty       => empty,
      data_count  => data_count);

  fifo_rst <= '1' when s_fifo = init else '0';
  wr_en    <= '1' when s_fifo = exec else '0';
--  wr_en    <= '1' when s_fifo = wr   else '0';
  ack      <= '1' when s_fifo = fini else '0';

  rd_en <= not (fmt_busy or empty);
--  rd_en <= '1' when s_fifo = rd else '0';

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        s_fifo <= idle;
--        rd_en  <= '0';
        cnt    <= (others => '0');
      else
        case s_fifo is
          when idle =>
--            rd_en <= '0';
            if en = '1' then
              s_fifo <= init;
            else
              s_fifo <= idle;
            end if;

          when init =>
            if full = '0' then
              s_fifo <= exec;
            else
              cnt    <= (others => '0');
              s_fifo <= init;
            end if;

          when exec =>
--            if almost_full = '1' then
--              s_fifo <= fini;
            if cnt = (cnt'range => '1') then
              s_fifo <= fini;
            else
              cnt    <= cnt + 1;
              s_fifo <= exec;
            end if;

--          when wr =>
--            if almost_full = '1' then
--              s_fifo <= rd;
--            else
--              s_fifo <= wr;
--            end if;

--          when rd =>
--            if empty = '1' then
--              s_fifo <= fini;
--            else
--              rd_en  <= not fmt_busy;
--              s_fifo <= rd;
--            end if;

          when fini => s_fifo <= idle;

          when others => null;
        end case;
      end if;
    end if;
  end process;

--  process(clk)
--  begin
--    if rising_edge(clk) then
--      if rst = '1' then
--        s_adc_ss <= idle;
--      else
--        case s_adc_ss is
--          when idle =>
--            if en = '1' then
--              s_adc_ss <= init;
--            else
--              s_adc_ss <= idle;
--            end if;

--          when init =>
--            s_adc_ss <= exec;

--          when exec =>
--            if ts < conv_std_logic_vector(131072, 24) then
--              s_adc_ss <= exec;
--            else
--              mem_wr_en <= '0';
--              s_adc_ss  <= fini;
--            end if;

--          when fini =>
--            ack      <= '1';
--            s_adc_ss <= idle;

--          when others => s_adc_ss <= idle;
--        end case;
--      end if;
--    end if;
--  end process;

--  busy <= '1' when s_adc_ss /= idle else '0';

end architecture Behavioral;
