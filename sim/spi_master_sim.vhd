-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/04/03 13:31:41
-- Design Name: 
-- Module Name: spi_master_sim - Behavioral
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

entity spi_master_sim is
end spi_master_sim;

architecture Behavioral of spi_master_sim is

  constant clk_period : time    := 5 ns;
  constant d_width    : integer := 16;
  constant slaves     : integer := 2;

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

  signal clk     : std_logic;
  signal rst     : std_logic;
  signal trg     : std_logic;
  signal cpol    : std_logic;
  signal cpha    : std_logic;
  signal cont    : std_logic;
  signal clk_div : integer;
  signal addr    : integer;
  signal txd     : std_logic_vector(d_width-1 downto 0);
  signal miso    : std_logic;
  signal sclk    : std_logic;
  signal ss_n    : std_logic_vector(slaves-1 downto 0);
  signal mosi    : std_logic;
  signal busy    : std_logic;
  signal rxd     : std_logic_vector(d_width-1 downto 0);

begin

  spi_master_inst : spi_master
    generic map (
      slaves  => slaves,
      d_width => d_width)
    port map (
      clk     => clk,
      rst     => rst,
      trg     => trg,
      cpol    => cpol,
      cpha    => cpha,
      cont    => cont,
      clk_div => clk_div,
      addr    => addr,
      txd     => txd,
      miso    => miso,
      sclk    => sclk,
      ss_n    => ss_n,
      mosi    => mosi,
      busy    => busy,
      rxd     => rxd);

  clk_proc : process
  begin
    clk <= '1';
    wait for clk_period/2;
    clk <= '0';
    wait for clk_period/2;
  end process;

  stim_proc : process
  begin
    -- init
    rst     <= '1';
    trg     <= '0';
    cpol    <= '0';
    cpha    <= '0';
    cont    <= '0';
    clk_div <= 1000;                    -- sclk = 100 kHz
    addr    <= 0;
    txd     <= (others => '0');
    wait for clk_period;
    rst     <= '0';

    wait for clk_period*3;

    -- ADC init
    cpol <= '1';
    cpha <= '0';
    addr <= 0;                          -- 0: ADC
    txd  <= x"12" & x"34";              -- address[7:0] & data[7:0]

    wait for clk_period;

    -- ADC TX
    trg <= '1';
    wait for clk_period;
    trg <= '0';

    wait for 200 us;

    -- ADC RX
    txd <= x"ab" & "ZZZZZZZZ";
    trg <= '1';
    wait for clk_period;
    trg <= '0';

    wait for 200 us;

    -- DAC init
    cpol <= '0';
    cpha <= '0';
    addr <= 1;                          -- 1: DAC
    txd  <= x"56" & x"89";              -- address[7:0] & data[7:0]

    wait for clk_period;

    -- DAC TX
    trg <= '1';
    wait for clk_period;
    trg <= '0';

    wait for 200 us;

    -- DAC RX
    txd <= x"cd" & "ZZZZZZZZ";
    trg <= '1';
    wait for clk_period;
    trg <= '0';

    wait;
  end process;

  RX_proc : process
  begin
    miso <= '0';
    wait for 400 us;
    miso <= '1';
    wait;
  end process;

end Behavioral;
