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
    ts_size       : integer;            -- bytes
    fmt_data_size : integer);           -- bytes
  port (
    clk              : in  std_logic;
    rst              : in  std_logic;
    en               : in  std_logic;
    ts               : in  std_logic_vector(ts_size*8-1 downto 0);
    fifo_almost_full : in  std_logic;
    ts_trg           : out std_logic;
    fifo_wr_en       : out std_logic;
    busy             : out std_logic;
    ack              : out std_logic;
    dout             : out std_logic_vector(7 downto 0));
end entity data_format;

architecture Behavioral of data_format is

  signal din     : fmt_data(fmt_data_size-1 downto 0);
  signal din_buf : fmt_data(fmt_data_size-1 downto 0);
  signal cnt     : integer range 0 to fmt_data_size-1 := 0;

  type fmt_state is (idle, init, exec, fini);
  signal s_fmt : fmt_state;

begin

  Timestamp_gen : for i in 0 to 4 generate
  begin
    din(i+1) <= ts(7+8*i downto 8*i);
  end generate Timestamp_gen;

  din(0)                        <= x"ff";              -- header
  din(fmt_data_size-1 downto 6) <= (others => x"00");  -- data

  Data_Format_SM_proc : process(clk)
  begin
    if (clk'event and clk = '1') then
      if rst = '1' then
        s_fmt      <= idle;
        din_buf    <= (others => x"00");
        fifo_wr_en <= '0';
        cnt        <= 0;
        ts_trg     <= '0';
        ack        <= '0';
      else
        case s_fmt is
          when idle =>
            ack <= '0';
            if en = '1' then
              s_fmt  <= init;
              ts_trg <= '1';
            else
              s_fmt <= idle;
            end if;

          when init =>
            din_buf    <= din;
            fifo_wr_en <= '1';
            s_fmt      <= exec;
            ts_trg     <= '0';
            cnt        <= 0;
            
          when exec =>
            if cnt = fmt_data_size-1 then
              s_fmt <= fini;
            else
              cnt <= cnt + 1;
            end if;

          when fini =>
            fifo_wr_en <= '0';
            ack        <= '1';
            s_fmt      <= idle;
            
          when others => s_fmt <= idle;
        end case;
      end if;
    end if;
  end process;

  dout <= din_buf(cnt);                 -- when s_fmt = exec else x"00";
  busy <= '1' when s_fmt /= idle else '0';

end architecture Behavioral;
