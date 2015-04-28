-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/03/11 17:58:52
-- Design Name: 
-- Module Name: rbcp - Behavioral
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

entity rbcp is
  generic (
    d_width : integer);
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    -- RBCP I/O
    rbcp_act  : in  std_logic;
    rbcp_addr : in  std_logic_vector(31 downto 0);
    rbcp_we   : in  std_logic;
    rbcp_wd   : in  std_logic_vector(7 downto 0);
    rbcp_re   : in  std_logic;
    rbcp_rd   : out std_logic_vector(7 downto 0);
    rbcp_ack  : out std_logic;
    -- Module I/O
    req       : out std_logic;
    ack       : in  std_logic;
    rxd       : in  std_logic_vector(d_width-1 downto 0);
    spi_txd   : out std_logic_vector(d_width-1 downto 0);
    sft_rst   : out std_logic);
end rbcp;

architecture Behavioral of rbcp is

  type rbcp_state is (init, idle, tx, fini);
  signal s_rbcp : rbcp_state;

--  component oneshot_pulse is
--    port (
--      clk : in  std_logic;
--      rst : in  std_logic;
--      d   : in  std_logic;
--      q   : out std_logic);
--  end component oneshot_pulse;

--  signal sft_rst_buf : std_logic;

begin

  RBCP_SM_proc : process(clk)
  begin
    if (clk'event and clk = '1') then
      if rst = '1' then
        s_rbcp   <= init;
        rbcp_ack <= '0';
        rbcp_rd  <= (others => '0');
        req      <= '0';
      else
        case s_rbcp is
          when init =>
            rbcp_ack <= '0';
            req      <= '0';
            if rbcp_act = '1' then
              s_rbcp <= idle;
            else
              s_rbcp <= init;
            end if;
            
          when idle =>
            if (rbcp_we xor rbcp_re) = '1' then
              req    <= '1';
              s_rbcp <= tx;
            else
              s_rbcp <= idle;
            end if;
            
          when tx =>
            req <= '0';
            if ack = '1' then
              s_rbcp <= fini;
            else
              s_rbcp <= tx;
            end if;

          when fini =>
            rbcp_ack <= '1';
            s_rbcp   <= init;
            rbcp_rd  <= rxd(7 downto 0);
            
          when others => s_rbcp <= init;
        end case;
      end if;
    end if;
  end process;

  process(clk)
  begin
    if (clk'event and clk = '1') then
      if rst = '1' then
        spi_txd <= (others => '0');
      else
        case rbcp_addr(31 downto 24) is
          -- ADC/DAC register control
          when x"10" =>                 -- ADC register write
            spi_txd <= rbcp_addr(7 downto 0) & rbcp_wd;
          when x"11" =>                 -- ADC register read
            spi_txd <= rbcp_addr(7 downto 0) & x"00";
          when x"20" =>                 -- DAC register write
            spi_txd <= '0' & "00" & rbcp_addr(4 downto 0) & rbcp_wd;
          when x"21" =>                 -- DAC register read
            spi_txd <= '1' & "00" & rbcp_addr(4 downto 0) & x"00";

          -- Snapshot of ADC data
--          when x"30" => sft_rst_buf <= '1';
--          when x"31" => sft_rst_buf <= '0';

          when others => null;
        end case;
      end if;
    end if;
  end process;

--  Oneshot_Pulse_ADC_Snapshot : oneshot_pulse
--    port map (
--      clk => clk,
--      rst => rst,
--      d   => sft_rst_buf,
--      q   => sft_rst);

end Behavioral;
