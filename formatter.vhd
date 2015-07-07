-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/05/28 10:55:26
-- Design Name: 
-- Module Name: formatter - Behavioral
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

entity formatter is
  generic (
    d_size : integer);                  -- bytes
  port (
    clk    : in     std_logic;
    rst    : in     std_logic;
    ts_rst : in     std_logic;
    en     : in     std_logic;
    din    : in     byte_array(d_size-1 downto 0);
    valid  : out    std_logic;
    busy   : out    std_logic;
    ack    : buffer std_logic;
    dout   : out    std_logic_vector(7 downto 0));
end entity formatter;

architecture Behavioral of formatter is

  -- header (1) + timestamp (5) + data + footer (1); (bytes)
  constant fmt_data_size : integer := d_size+7;

  signal ts       : byte_array(4 downto 0);
  signal ts_buf   : std_logic_vector(39 downto 0);
  signal din_buf  : byte_array(d_size-1 downto 0);
  signal fmt_data : byte_array(fmt_data_size-1 downto 0);
  signal cnt      : integer range 0 to fmt_data_size-1;

  type fmt_state is (idle, init, exec, fini);
  signal s_fmt : fmt_state;

begin

  fmt_data(0)                        <= x"ff";    -- header
  fmt_data(5 downto 1)               <= ts;       -- timestamp
  fmt_data(fmt_data_size-2 downto 6) <= din_buf;  -- data
  fmt_data(fmt_data_size-1)          <= x"ee";    -- footer

  valid <= '1' when s_fmt = exec  else '0';
  ack   <= '1' when s_fmt = fini  else '0';
  busy  <= '1' when s_fmt /= idle else '0';

  dout <= fmt_data(cnt);

  Formatter_SM : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        s_fmt <= idle;
        cnt   <= 0;
      else
        case s_fmt is
          when idle =>
            cnt <= 0;
            if en = '1' then
              s_fmt <= init;
            else
              s_fmt <= idle;
            end if;

          when init =>
            din_buf <= din;
            s_fmt   <= exec;

          when exec =>
            if cnt = fmt_data_size-1 then
              s_fmt <= fini;
            else
              cnt <= cnt + 1;
            end if;

          when fini => s_fmt <= idle;

          when others => s_fmt <= idle;
        end case;
      end if;
    end if;
  end process;

  Timestamp_gen : for i in 0 to 4 generate
    ts(4-i) <= ts_buf(8*i+7 downto 8*i);
  end generate Timestamp_gen;

  Timestampe_proc : process(clk)
  begin
    if rising_edge(clk) then
      if (ts_rst or rst) = '1' then
        ts_buf <= (others => '0');
      else
        ts_buf <= ts_buf + ack;
      end if;
    end if;
  end process;

--  Timestampe_proc : process(ts_rst, clk)
--  begin
--    if ts_rst = '1' then
--      ts_buf <= (others => '0');
--    elsif rising_edge(clk) then
--      ts_buf <= ts_buf + ack;
--    else
--      null;
--    end if;
--  end process;

end architecture Behavioral;
