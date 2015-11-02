-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/06/23 12:22:36
-- Design Name: 
-- Module Name: downsampler - Behavioral
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

entity downsampler is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    din   : in  std_logic_vector(30 downto 0);
    dout  : out std_logic_vector(IQ_DS_DATA_WIDTH-1 downto 0);
    valid : out std_logic);
end entity downsampler;

architecture Behavioral of downsampler is

  component accumulator is
    port (
      b    : in  std_logic_vector(30 downto 0);
      clk  : in  std_logic;
      ce   : in  std_logic;
      sclr : in  std_logic;
      q    : out std_logic_vector(IQ_DS_DATA_WIDTH-1 downto 0));
  end component accumulator;

  signal sclr    : std_logic;
  signal din_buf : std_logic_vector(30 downto 0);
  signal d_acc   : std_logic_vector(IQ_DS_DATA_WIDTH-1 downto 0);

  type ds_state is (idle, init, latency, exec);
  signal s_ds : ds_state;

begin

  Accumulator_inst : accumulator
    port map (
      b    => din_buf,
      clk  => clk,
      ce   => "not"(rst),
      sclr => sclr,
      q    => d_acc);

  sclr    <= '1' when s_ds = init                   else '0';
  din_buf <= din when s_ds = latency or s_ds = exec else (others => '0');

  Downsample_proc : process(clk)
    variable cnt_latency : integer range 0 to LATENCY_ACC-1     := 0;
    variable cnt_ds      : integer range 0 to DOWNSAMPLE_RATE-1 := 0;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        dout        <= (others => '0');
        valid       <= '0';
        cnt_latency := 0;
        cnt_ds      := 0;
        s_ds        <= idle;
      else
        case s_ds is
          when idle => s_ds <= init;

          when init =>
            cnt_latency := 0;
            cnt_ds      := 0;
            valid       <= '0';
            s_ds        <= latency;

          when latency =>
            if cnt_latency = LATENCY_ACC-1 then
              s_ds <= exec;
            else
              cnt_latency := cnt_latency + 1;
              s_ds        <= latency;
            end if;

          when exec =>
            if cnt_ds = DOWNSAMPLE_RATE-1 then
              dout  <= d_acc;
              valid <= '1';
              s_ds  <= init;
            else
              cnt_ds := cnt_ds + 1;
            end if;

          when others => s_ds <= idle;
        end case;
      end if;
    end if;
  end process;

end architecture Behavioral;
