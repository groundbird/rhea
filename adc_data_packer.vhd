-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/05/22 18:00:29
-- Design Name: 
-- Module Name: adc_data_packer - Behavioral
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

entity adc_data_packer is
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    en      : in  std_logic;
    adc_cha : in  std_logic_vector(13 downto 0);
    adc_chb : in  std_logic_vector(13 downto 0);
    dout    : out fmt_data(raw_data_size-1 downto 0);
    ack     : out std_logic);
end entity adc_data_packer;

architecture Behavioral of adc_data_packer is

  signal cnt     : integer;
  signal cha_fmt : std_logic_vector(15 downto 0);
  signal chb_fmt : std_logic_vector(15 downto 0);

  type data_packer_state is (idle, init, exec, fini);
  signal s_pack : data_packer_state;

begin

  cha_fmt <= "00" & adc_cha;
  chb_fmt <= "00" & adc_chb;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        dout <= (others => x"00");
      else
        case s_pack is
          when idle =>
            ack <= '0';
            cnt <= 0;
            if en = '1' then
              s_pack <= init;
            else
              s_pack <= idle;
            end if;

          when init =>
            s_pack <= exec;

          when exec =>
            if cnt < 250 then
              dout(4*cnt)   <= cha_fmt(15 downto 8);
              dout(4*cnt+1) <= cha_fmt(7 downto 0);
              dout(4*cnt+2) <= chb_fmt(15 downto 8);
              dout(4*cnt+3) <= chb_fmt(7 downto 0);
            else
              for i in range 1000 to raw_data_size-1 loop
                dout(i) <= x"00";
              end loop;  -- i
              s_pack <= fini;
            end if;

          when fini =>
            ack    <= '1';
            s_pack <= idle;

          when others => idle;
        end case;
      end if;
    end if;
  end process;

end architecture Behavioral;
