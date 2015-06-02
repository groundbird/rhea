-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/04/20 18:19:40
-- Design Name: 
-- Module Name: data_format - Behavioral
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

entity data_format is
  generic (
    ts_size : integer;                  -- bytes
    d_size  : integer);                 -- bytes
  port (
    clk              : in  std_logic;
    rst              : in  std_logic;
    wr_en            : in  std_logic;
    ts               : in  byte_array(ts_size-1 downto 0);
    fifo_almost_full : in  std_logic;
    din              : in  byte_array(d_size-1 downto 0);
    fifo_wr_en       : out std_logic;
    valid            : out std_logic;
    busy             : out std_logic;
    ack              : out std_logic;
    dout             : out std_logic_vector(7 downto 0));
end entity data_format;

architecture Behavioral of data_format is

  -- header + timestamp + data + footer (bytes)
  constant fmt_data_size : integer := ts_size+d_size+2;

  signal fmt_data : byte_array(fmt_data_size-1 downto 0);
  signal cnt      : integer;

  type fmt_state is (idle, init, exec, fini);
  signal s_fmt : fmt_state;

begin

--  Timestamp_gen : for i in 0 to ts_size-1 generate
--  begin
--    fmt_data(ts_size-i) <= ts(7+8*i downto 8*i);
--  end generate Timestamp_gen;

  fmt_data(0)                                <= x"ff";  -- header
  fmt_data(ts_size downto 1)                 <= ts;     -- timestamp
  fmt_data(fmt_data_size-2 downto ts_size+1) <= din;    -- data
  fmt_data(fmt_data_size-1)                  <= x"ee";  -- footer

  valid      <= '1' when s_fmt = init  else '0';
  fifo_wr_en <= '1' when s_fmt = exec  else '0';
  ack        <= '1' when s_fmt = fini  else '0';
  busy       <= '1' when s_fmt /= idle else '0';

  Data_Format_SM_proc : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        s_fmt <= idle;
        cnt   <= 0;
      else
        case s_fmt is
          when idle =>
            cnt <= 0;
            if wr_en = '1' and fifo_almost_full = '0' then
              s_fmt <= init;
            else
              s_fmt <= idle;
            end if;

          when init => s_fmt <= exec;

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

  dout <= fmt_data(cnt);

end architecture Behavioral;
