-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/03/16 14:09:16
-- Design Name: 
-- Module Name: rbcp_sim - Behavioral
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

entity rbcp_sim is
end rbcp_sim;

architecture Behavioral of rbcp_sim is

  constant clk_period : time    := 5 ns;  -- 200 MHz
  constant d_width    : integer := 16;
  constant slaves     : integer := 2;

  component rbcp is
    generic (
      d_width : integer);
    port (
      clk       : in  std_logic;
      rst       : in  std_logic;
      -- RBCP
      rbcp_act  : in  std_logic;
      rbcp_addr : in  std_logic_vector(31 downto 0);
      rbcp_we   : in  std_logic;
      rbcp_wd   : in  std_logic_vector(7 downto 0);
      rbcp_re   : in  std_logic;
      rbcp_rd   : out std_logic_vector(7 downto 0);
      rbcp_ack  : out std_logic;
      -- SPI
      spi_req   : out std_logic;
      spi_ack   : in  std_logic;
      reg_txd   : out std_logic_vector(d_width-1 downto 0);
      reg_rxd   : in  std_logic_vector(d_width-1 downto 0));
  end component rbcp;

  signal clk       : std_logic;
  signal rst       : std_logic;
  signal rbcp_act  : std_logic;
  signal rbcp_addr : std_logic_vector(31 downto 0);
  signal rbcp_we   : std_logic;
  signal rbcp_wd   : std_logic_vector(7 downto 0);
  signal rbcp_re   : std_logic;
  signal rbcp_rd   : std_logic_vector(7 downto 0);
  signal rbcp_ack  : std_logic;
  signal spi_req   : std_logic;
  signal spi_ack   : std_logic;
  signal reg_txd   : std_logic_vector(d_width-1 downto 0);
  signal reg_rxd   : std_logic_vector(d_width-1 downto 0);

  component spi_master is
    generic (
      slaves  : integer;
      d_width : integer);
    port (
      clk     : in     std_logic;
      rst     : in     std_logic;
      trg     : in     std_logic;
      cpol    : in     std_logic;
      cpha    : in     std_logic;
      cont    : in     std_logic;
      clk_div : in     integer;
      addr    : in     integer;
      txd     : in     std_logic_vector(d_width-1 downto 0);
      miso    : in     std_logic;
      sclk    : buffer std_logic;
      ss_n    : buffer std_logic_vector(slaves-1 downto 0);
      mosi    : out    std_logic;
      busy    : out    std_logic;
      rxd     : out    std_logic_vector(d_width-1 downto 0));
  end component spi_master;

  signal cpol      : std_logic;
  signal cpha      : std_logic;
  signal cont      : std_logic;
  signal clk_div   : integer;
  signal addr      : integer;
  signal miso      : std_logic;
  signal spi_sclk  : std_logic;
  signal ss_n      : std_logic_vector(slaves-1 downto 0);
  signal spi_sdata : std_logic;
  signal busy      : std_logic;
  signal busy_buf  : std_logic;

begin

  RBCP_inst_sim : rbcp
    generic map (
      d_width => d_width)
    port map (
      clk       => clk,
      rst       => rst,
      rbcp_act  => rbcp_act,
      rbcp_addr => rbcp_addr,
      rbcp_we   => rbcp_we,
      rbcp_wd   => rbcp_wd,
      rbcp_re   => rbcp_re,
      rbcp_rd   => rbcp_rd,
      rbcp_ack  => rbcp_ack,
      spi_req   => spi_req,
      spi_ack   => spi_ack,
      reg_txd   => reg_txd,
      reg_rxd   => reg_rxd);

  SPI_Master_inst_sim : spi_master
    generic map (
      slaves  => slaves,
      d_width => d_width)
    port map (
      clk     => clk,
      rst     => rst,
      trg     => spi_req,
      cpol    => cpol,
      cpha    => cpha,
      cont    => cont,
      clk_div => clk_div,
      addr    => addr,
      txd     => reg_txd,
      miso    => miso,
      sclk    => spi_sclk,
      ss_n    => ss_n,
      mosi    => spi_sdata,
      busy    => busy,
      rxd     => reg_rxd);

  -- clock process definitions
  clk_proc : process
  begin
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
  end process;

  -- stimulus process
  stim_proc : process
  begin
    -- initialize
    rst       <= '1';
    rbcp_act  <= '0';
    rbcp_addr <= (others => '0');
    rbcp_wd   <= (others => '0');
    rbcp_we   <= '0';
    rbcp_re   <= '0';
    cpha      <= '0';
    cont      <= '0';
    clk_div   <= 1000;
    wait for clk_period*5;
    rst       <= '0';

    -- write ADC reg
    rbcp_act  <= '1';
    rbcp_addr <= x"10000003";
    rbcp_wd   <= x"08";
    wait for clk_period*5;
    rbcp_we   <= '1';
    wait for clk_period;
    rbcp_we   <= '0';

    wait for 200 us;

    -- read ADC reg
    rbcp_addr <= x"11000017";
    wait for clk_period*5;
    rbcp_re   <= '1';
    wait for clk_period;
    rbcp_re   <= '0';

    wait for 200 us;

    -- write DAC reg
    rbcp_addr <= x"200000db";
    rbcp_wd   <= x"42";
    wait for clk_period;
    rbcp_we   <= '1';
    wait for clk_period;
    rbcp_we   <= '0';

    wait for 200 us;

    -- read DAC reg
    rbcp_addr <= x"21000005";
    wait for clk_period;
    rbcp_re   <= '1';
    wait for clk_period;
    rbcp_re   <= '0';

    wait;
  end process;

  RX_proc : process
  begin
    miso <= '0';
    wait for 200 us;
    miso <= '1';
    wait for 200 us;
    miso <= '0';
    wait;
  end process;

  process(clk)
  begin
    if (clk'event and clk = '1') then
      if rst = '1' then
        busy_buf <= '0';
      else
        busy_buf <= busy;
      end if;
    end if;
  end process;

  spi_ack <= '1' when (busy_buf = '1' and busy = '0') else '0';

  addr <= 0 when rbcp_addr(31 downto 28) = x"1" else     -- ADC
          1 when rbcp_addr(31 downto 28) = x"2" else 0;  -- DAC

--  cpol <= '1' when ss_n(0) = '0' else       -- falling edge
--          '0' when ss_n(1) = '0' else '0';  -- risigng edge

--  process(clk)
--  begin
--    if (clk'event and clk = '1') then
--      if (spi_req = '1' and rbcp_addr(31 downto 28) = x"1") then
--        cpol <= '1';
--      else
--        cpol <= '0';
--      end if;
--    end if;
--  end process;

  cpol <= spi_req when rbcp_addr(31 downto 28) = x"1" else '0';

end Behavioral;
