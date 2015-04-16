-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/04/08 14:47:05
-- Design Name: 
-- Module Name: rhea - Behavioral
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

entity rhea is
  port (
    -- KC705 Resources
    sysclk_p       : in     std_logic;
    sysclk_n       : in     std_logic;
    cpu_reset      : in     std_logic;
    gpio_led       : out    std_logic_vector(7 downto 0);
    gpio_dip_sw    : in     std_logic_vector(3 downto 0);
    gpio_sw_n      : in     std_logic;
    gpio_sw_e      : in     std_logic;
    gpio_sw_s      : in     std_logic;
    gpio_sw_w      : in     std_logic;
    gpio_sw_c      : in     std_logic;
    -- ADC I/O
    clk_ab_p       : in     std_logic;  -- ADC sample clock
    clk_ab_n       : in     std_logic;
    cha_p          : in     std_logic_vector(6 downto 0);
    cha_n          : in     std_logic_vector(6 downto 0);
    chb_p          : in     std_logic_vector(6 downto 0);
    chb_n          : in     std_logic_vector(6 downto 0);
    -- ADC/DAC Register Control I/O
    spi_sclk25     : buffer std_logic;
    spi_sdata25    : buffer std_logic;
    adc_n_en25     : buffer std_logic;
    dac_n_en25     : buffer std_logic;
    adc_sdo25      : in     std_logic;
    dac_sdo25      : in     std_logic;
    adc_reset25    : out    std_logic;
    txenable25     : out    std_logic;
    -- PHY I/O
    phy_mdio       : inout  std_logic;
    phy_mdc        : out    std_logic;
    phy_rstn       : out    std_logic;
    phy_crs        : in     std_logic;
    phy_col        : in     std_logic;
    phy_rxclk      : in     std_logic;
    phy_rxer       : in     std_logic;
    phy_rxctl_rxdv : in     std_logic;
    phy_rxd        : in     std_logic_vector(7 downto 0);
    phy_txc_gtxclk : out    std_logic;
    phy_txclk      : in     std_logic;
    phy_txer       : out    std_logic;
    phy_txctl_txen : out    std_logic;
    phy_txd        : out    std_logic_vector(7 downto 0));
end rhea;

architecture Behavioral of rhea is

  component rs_ff is
    port (
      r  : in  std_logic;
      s  : in  std_logic;
      q  : out std_logic;
      qb : out std_logic);
  end component rs_ff;

  signal cpu_rst : std_logic;

  component clk_wiz_0 is
    port (
      clk_in1_p : in  std_logic;        -- sysclk_p
      clk_in1_n : in  std_logic;        -- sysclk_n
      clk_out1  : out std_logic;        -- 200 MHz
      clk_out2  : out std_logic;        -- 125 MHz for SiTCP
      clk_out3  : out std_logic;        -- 100 MHz
      reset     : in  std_logic;        -- cpu_rst
      locked    : out std_logic);
  end component clk_wiz_0;

  signal clk_200 : std_logic;
  signal clk_125 : std_logic;
  signal clk_100 : std_logic;
  signal sys_rst : std_logic;
  signal clk_loc : std_logic;

  component clk_wiz_1 is
    port (
      clk_in1_p : in  std_logic;        -- clk_ab_p
      clk_in1_n : in  std_logic;        -- clk_ab_n
      clk_out1  : out std_logic;        -- clk_adc
      reset     : in  std_logic;        -- cpu_rst
      locked    : out std_logic);
  end component clk_wiz_1;

  signal clk_adc : std_logic;
  signal adc_rst : std_logic;
  signal adc_loc : std_logic;

  component adc is
    port (
      clk     : in  std_logic;
      rst     : in  std_logic;
      -- ADC I/O
      cha_p   : in  std_logic_vector(6 downto 0);
      cha_n   : in  std_logic_vector(6 downto 0);
      chb_p   : in  std_logic_vector(6 downto 0);
      chb_n   : in  std_logic_vector(6 downto 0);
      adc_cha : out std_logic_vector(13 downto 0);
      adc_chb : out std_logic_vector(13 downto 0));
  end component adc;

  signal adc_cha : std_logic_vector(13 downto 0);
  signal adc_chb : std_logic_vector(13 downto 0);

  component sitcp is
    port (
      -- System I/F
      clk_200        : in    std_logic;
      clk_125        : in    std_logic;
      rst            : in    std_logic;
      sitcp_rst      : out   std_logic;
      -- MII/GMII I/F signal
      gmii_1000m     : in    std_logic;
      -- PHY I/F
      phy_mdio       : inout std_logic;
--    phy_intn       : in  std_logic;     -- open drain output from PHY
      phy_mdc        : out   std_logic;
      phy_rstn       : out   std_logic;
      phy_crs        : in    std_logic;
      phy_col        : in    std_logic;
      phy_rxclk      : in    std_logic;
      phy_rxer       : in    std_logic;
      phy_rxctl_rxdv : in    std_logic;
      phy_rxd        : in    std_logic_vector(7 downto 0);
      phy_txc_gtxclk : out   std_logic;
      phy_txclk      : in    std_logic;
      phy_txer       : out   std_logic;
      phy_txctl_txen : out   std_logic;
      phy_txd        : out   std_logic_vector(7 downto 0);
--    sgmii_tx_p     : out std_logic;     -- SGMII transmit data
--    sgmii_tx_n     : out std_logic;
--    sgmii_rx_p     : in  std_logic;     -- SGMII receive data
--    sgmii_rx_n     : in  std_logic;
      -- TCP
      tcp_open_req   : in    std_logic;
      tcp_open_ack   : out   std_logic;
      tcp_error      : out   std_logic;
      tcp_close_req  : out   std_logic;
      tcp_close_ack  : in    std_logic;
      tcp_rxd        : out   std_logic_vector(7 downto 0);
      tcp_tx_full    : out   std_logic;
      tcp_tx_wr      : in    std_logic;
      tcp_txd        : in    std_logic_vector(7 downto 0);
      -- UDP (RBCP)
      rbcp_act       : out   std_logic;
      rbcp_addr      : out   std_logic_vector(31 downto 0);
      rbcp_wd        : out   std_logic_vector(7 downto 0);
      rbcp_we        : out   std_logic;
      rbcp_re        : out   std_logic;
      rbcp_ack       : in    std_logic;
      rbcp_rd        : in    std_logic_vector(7 downto 0));
  end component sitcp;

  signal sitcp_rst     : std_logic;
  signal gmii_1000m    : std_logic;
  signal tcp_open_req  : std_logic;
  signal tcp_open_ack  : std_logic;
  signal tcp_error     : std_logic;
  signal tcp_close_req : std_logic;
  signal tcp_close_ack : std_logic;
  signal tcp_rxd       : std_logic_vector(7 downto 0);
  signal tcp_tx_full   : std_logic;
  signal tcp_tx_wr     : std_logic;
  signal tcp_txd       : std_logic_vector(7 downto 0);
  signal rbcp_act      : std_logic;
  signal rbcp_addr     : std_logic_vector(31 downto 0);
  signal rbcp_wd       : std_logic_vector(7 downto 0);
  signal rbcp_we       : std_logic;
  signal rbcp_re       : std_logic;
  signal rbcp_ack      : std_logic;
  signal rbcp_rd       : std_logic_vector(7 downto 0);

  component rbcp is
    generic (
      d_width : integer);
    port (
      clk       : in  std_logic;
      rst       : in  std_logic;
      -- RBCP I/F
      rbcp_act  : in  std_logic;
      rbcp_addr : in  std_logic_vector(31 downto 0);
      rbcp_we   : in  std_logic;
      rbcp_wd   : in  std_logic_vector(7 downto 0);
      rbcp_re   : in  std_logic;
      rbcp_rd   : out std_logic_vector(7 downto 0);
      rbcp_ack  : out std_logic;
      -- Module I/F
      req       : out std_logic;
      ack       : in  std_logic;
      txd       : out std_logic_vector(d_width-1 downto 0);
      rxd       : in  std_logic_vector(d_width-1 downto 0));
  end component rbcp;

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

  signal spi_req  : std_logic;
  signal cpol     : std_logic;
  signal cpha     : std_logic;
  signal cont     : std_logic;
  signal clk_div  : integer;
  signal addr     : integer;
  signal spi_txd  : std_logic_vector(15 downto 0);
  signal miso     : std_logic;
  signal ss_n     : std_logic_vector(1 downto 0);
  signal spi_busy : std_logic;
  signal spi_rxd  : std_logic_vector(15 downto 0);

  signal spi_busy_buf : std_logic;
  signal spi_ack      : std_logic;

  ---------------------------------------------------------------------------
  -- Debug
  ---------------------------------------------------------------------------
  signal debug : std_logic_vector(7 downto 0);
  signal cnt   : std_logic_vector(24 downto 0);
  
begin

  ---------------------------------------------------------------------------
  -- Clock/Reset
  ---------------------------------------------------------------------------
  System_Clock : clk_wiz_0
    port map (
      clk_in1_p => sysclk_p,
      clk_in1_n => sysclk_n,
      clk_out1  => clk_200,
      clk_out2  => clk_125,
      clk_out3  => clk_100,
      reset     => cpu_rst,
      locked    => clk_loc);

  ADC_Sample_Clock : clk_wiz_1
    port map (
      clk_in1_p => clk_ab_p,
      clk_in1_n => clk_ab_n,
      clk_out1  => clk_adc,
      reset     => cpu_rst,
      locked    => adc_loc);

  RSFF_CPU_Reset : rs_ff
    port map (
      r  => cpu_reset,
      s  => not cpu_reset,
      q  => open,
      qb => cpu_rst);

  System_Reset : process(clk_200)
  begin
    if (clk_200'event and clk_200 = '1') then
      sys_rst <= not clk_loc;
    end if;
  end process;

  ADC_Reset : process(clk_adc)
  begin
    if (clk_adc'event and clk_adc = '1') then
      adc_rst <= not adc_loc;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- ADC
  ---------------------------------------------------------------------------
  ADC_inst : adc
    port map (
      clk     => clk_adc,
      rst     => adc_rst,
      cha_p   => cha_p,
      cha_n   => cha_n,
      chb_p   => chb_p,
      chb_n   => chb_n,
      adc_cha => adc_cha,
      adc_chb => adc_chb);

  RSFF_ADC_Register_Reset : rs_ff
    port map (
      r  => gpio_sw_c,
      s  => not gpio_sw_c,
      q  => open,
      qb => adc_reset25);

  ---------------------------------------------------------------------------
  -- SiTCP
  ---------------------------------------------------------------------------
  SiTCP_inst : sitcp
    port map (
      clk_200        => clk_200,
      clk_125        => clk_125,
      rst            => sys_rst,
      sitcp_rst      => sitcp_rst,
      gmii_1000m     => gmii_1000m,
      phy_mdio       => phy_mdio,
      phy_mdc        => phy_mdc,
      phy_rstn       => phy_rstn,
      phy_crs        => phy_crs,
      phy_col        => phy_col,
      phy_rxclk      => phy_rxclk,
      phy_rxer       => phy_rxer,
      phy_rxctl_rxdv => phy_rxctl_rxdv,
      phy_rxd        => phy_rxd,
      phy_txc_gtxclk => phy_txc_gtxclk,
      phy_txclk      => phy_txclk,
      phy_txer       => phy_txer,
      phy_txctl_txen => phy_txctl_txen,
      phy_txd        => phy_txd,
      tcp_open_req   => tcp_open_req,
      tcp_open_ack   => tcp_open_ack,
      tcp_error      => tcp_error,
      tcp_close_req  => tcp_close_req,
      tcp_close_ack  => tcp_close_ack,
      tcp_rxd        => tcp_rxd,
      tcp_tx_full    => tcp_tx_full,
      tcp_tx_wr      => tcp_tx_wr,
      tcp_txd        => tcp_txd,
      rbcp_act       => rbcp_act,
      rbcp_addr      => rbcp_addr,
      rbcp_wd        => rbcp_wd,
      rbcp_we        => rbcp_we,
      rbcp_re        => rbcp_re,
      rbcp_ack       => rbcp_ack,
      rbcp_rd        => rbcp_rd);

  gmii_1000m <= gpio_dip_sw(0);         -- (0: 100MbE, 1: GbE)

  ---------------------------------------------------------------------------
  -- RBCP
  ---------------------------------------------------------------------------
  RBCP_inst : rbcp
    generic map (
      d_width => 16)
    port map (
      clk       => clk_200,
      rst       => sitcp_rst,
      rbcp_act  => rbcp_act,
      rbcp_addr => rbcp_addr,
      rbcp_we   => rbcp_we,
      rbcp_wd   => rbcp_wd,
      rbcp_re   => rbcp_re,
      rbcp_rd   => rbcp_rd,
      rbcp_ack  => rbcp_ack,
      req       => spi_req,
      ack       => spi_ack,
      txd       => spi_txd,
      rxd       => spi_rxd);

  ---------------------------------------------------------------------------
  -- SPI Control
  ---------------------------------------------------------------------------
  SPI_Master_inst : spi_master
    generic map (
      slaves  => 2,
      d_width => 16)
    port map (
      clk     => clk_200,
      rst     => sys_rst,
      trg     => spi_req,
      cpol    => cpol,
      cpha    => '0',
      cont    => '0',
      clk_div => 1000,                  -- sclk = 100 kHz
      addr    => addr,
      txd     => spi_txd,
      miso    => miso,
      sclk    => spi_sclk25,
      ss_n    => ss_n,
      mosi    => spi_sdata25,
      busy    => spi_busy,
      rxd     => spi_rxd);

  adc_n_en25 <= ss_n(0);
  dac_n_en25 <= ss_n(1);

  miso <= adc_sdo25 when ss_n(0) = '0' else
          dac_sdo25 when ss_n(1) = '0' else '0';
  
  cpol <= spi_req when rbcp_addr(31 downto 28) = x"1" else '0';

  addr <= 0 when rbcp_addr(31 downto 28) = x"1" else     -- ADC
          1 when rbcp_addr(31 downto 28) = x"2" else 0;  -- DAC

  process(clk_200)
  begin
    if (clk_200'event and clk_200 = '1') then
      if sys_rst = '1' then
        spi_busy_buf <= '0';
      else
        spi_busy_buf <= spi_busy;
      end if;
    end if;
  end process;

  spi_ack <= '1' when (spi_busy_buf = '1' and spi_busy = '0') else '0';

  ---------------------------------------------------------------------------
  -- GPIO LED
  ---------------------------------------------------------------------------
  gpio_led <= adc_cha(13 downto 6) when gpio_dip_sw(3 downto 1) = "000" else
              adc_chb(13 downto 6) when gpio_dip_sw(3 downto 1) = "001" else
              debug                when gpio_dip_sw(3 downto 1) = "010" else x"00";

  ---------------------------------------------------------------------------
  -- Debug
  ---------------------------------------------------------------------------
  process(clk_adc)
  begin
    if rising_edge(clk_adc) then
      if adc_rst = '1' then
        cnt <= (others => '0');
      else
        cnt <= cnt + 1;
      end if;
    end if;
  end process;

  debug(7) <= cnt(24);

end Behavioral;