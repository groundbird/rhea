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

entity adc_snapshot is
  generic (
    ts_size : integer;                  -- bytes
    d_cnt   : integer);                 -- fmt_data_size*d_cnt bytes (1 MB)
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    trg    : in  std_logic;
    ts     : in  std_logic_vector(ts_size*8-1 downto 0);
    fmt_en : out std_logic;
    ack    : out std_logic);
end entity adc_snapshot;

architecture Behavioral of adc_snapshot is

  type adc_ss_state is (idle, init, exec, fini);
  signal s_adc_ss : adc_ss_state;

begin

  ADC_Snapshot_SM_proc : process(clk)
  begin
    if (clk'event and clk = '1') then
      if rst = '1' then
        fmt_en   <= '0';
        s_adc_ss <= idle;
        ack      <= '0';
      else
        case s_adc_ss is
          when idle =>
            ack <= '0';
            if trg = '1' then
              s_adc_ss <= init;
            else
              s_adc_ss <= idle;
            end if;
            
          when init =>
            fmt_en   <= '1';
            s_adc_ss <= exec;

          when exec =>
            if ts = conv_std_logic_vector(d_cnt-1, ts_size*8) then
              s_adc_ss <= fini;
            else
              s_adc_ss <= exec;
            end if;

          when fini =>
            ack      <= '1';
            fmt_en   <= '0';
            s_adc_ss <= idle;

          when others => s_adc_ss <= idle;
        end case;
      end if;
    end if;
  end process;

end architecture Behavioral;
