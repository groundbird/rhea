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

library work;
use work.rhea_pkg.all;

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

  component falling_edge_detector is
    port (
      clk : in  std_logic;
      d   : in  std_logic;
      q   : out std_logic);
  end component falling_edge_detector;

  signal spi_ack : std_logic;

  component system_clock is
    port (
      clk_in1_p : in  std_logic;        -- sysclk_p
      clk_in1_n : in  std_logic;        -- sysclk_n
      clk_out1  : out std_logic;        -- 200 MHz
      clk_out2  : out std_logic;        -- 125 MHz for SiTCP
      reset     : in  std_logic;        -- cpu_rst
      locked    : out std_logic);
  end component system_clock;

  signal clk_200 : std_logic;
  signal clk_125 : std_logic;
  signal sys_rst : std_logic;
  signal clk_loc : std_logic;

  component adc_clock is
    port (
      clk_in1_p : in  std_logic;        -- clk_ab_p
      clk_in1_n : in  std_logic;        -- clk_ab_n
      clk_out1  : out std_logic;        -- clk_adc
      reset     : in  std_logic;        -- cpu_rst
      locked    : out std_logic);
  end component adc_clock;

  signal clk_adc : std_logic;
  signal adc_rst : std_logic;
  signal adc_loc : std_logic;

  component adc is
    port (
      clk        : in  std_logic;
      rst        : in  std_logic;
      -- ADC I/O
      cha_p      : in  std_logic_vector(6 downto 0);
      cha_n      : in  std_logic_vector(6 downto 0);
      chb_p      : in  std_logic_vector(6 downto 0);
      chb_n      : in  std_logic_vector(6 downto 0);
      adc_data_a : out std_logic_vector(13 downto 0);
      adc_data_b : out std_logic_vector(13 downto 0));
  end component adc;

  signal adc_data_a : std_logic_vector(13 downto 0);
  signal adc_data_b : std_logic_vector(13 downto 0);

  component adc_snapshot is
    port (
      clk           : in     std_logic;
      rst           : in     std_logic;
      en            : in     std_logic;
      fmt_busy      : in     std_logic;
      adc_data_a    : in     std_logic_vector(13 downto 0);
      adc_data_b    : in     std_logic_vector(13 downto 0);
      wr_data_count : in     std_logic_vector(16 downto 0);
      dout          : out    byte_array(3 downto 0);
      rd_en         : buffer std_logic;
      ack           : out    std_logic);
  end component adc_snapshot;

  signal adc_ss_trg  : std_logic;
  signal adc_ss_ack  : std_logic;
  signal adc_ss_data : byte_array(3 downto 0);

  component formatter is
    generic (
      d_size : integer);                -- bytes
    port (
      clk        : in     std_logic;
      rst        : in     std_logic;
      ts_rst     : in     std_logic;
      en         : in     std_logic;
      din        : in     byte_array(d_size-1 downto 0);
      fifo_wr_en : out    std_logic;
      busy       : out    std_logic;
      ack        : buffer std_logic;
      dout       : out    std_logic_vector(7 downto 0));
  end component formatter;

  signal fmt_en   : std_logic;
  signal fmt_din  : byte_array(d_size-1 downto 0);
  signal fmt_busy : std_logic;
  signal fmt_ack  : std_logic;
  signal fmt_dout : std_logic_vector(7 downto 0);

  component data_transfer_to_sitcp is
    port (
      rst              : in  std_logic;
      wr_clk           : in  std_logic;
      rd_clk           : in  std_logic;
      fifo_wr_en       : in  std_logic;
      fifo_almost_full : out std_logic;
      tcp_open_ack     : in  std_logic;
      tcp_tx_full      : in  std_logic;
      din              : in  std_logic_vector(7 downto 0);
      tcp_txd          : out std_logic_vector(7 downto 0);
      tcp_tx_wr        : out std_logic;
      wr_data_count    : out std_logic_vector(16 downto 0));
  end component data_transfer_to_sitcp;

  signal fifo_wr_en       : std_logic;
  signal fifo_almost_full : std_logic;
  signal fifo_din         : std_logic_vector(7 downto 0);
  signal wr_data_count    : std_logic_vector(16 downto 0);

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
      rxd       : in  std_logic_vector(d_width-1 downto 0);
      spi_txd   : out std_logic_vector(d_width-1 downto 0);
      sft_rst   : out std_logic);
  end component rbcp;

  signal sft_rst      : std_logic;
  signal rbcp_mdl_req : std_logic;
  signal rbcp_mdl_ack : std_logic;
  signal rbcp_mdl_rxd : std_logic_vector(15 downto 0);
  signal rbcp_id      : std_logic_vector(3 downto 0);

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

  component dds is
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      en    : in  std_logic;
      pinc  : in  std_logic_vector(31 downto 0);
      valid : out std_logic;
      cos   : out std_logic_vector(15 downto 0);
      sin   : out std_logic_vector(15 downto 0);
      busy  : out std_logic;
      ack   : out std_logic);
  end component dds;

  signal dds_en    : std_logic;
  signal dds_rst   : std_logic;
  signal pinc      : std_logic_vector(31 downto 0);
  signal dds_valid : std_logic;
  signal cos       : std_logic_vector(15 downto 0);
  signal sin       : std_logic_vector(15 downto 0);
  signal dds_busy  : std_logic;
  signal dds_ack   : std_logic;

  ---------------------------------------------------------------------------
  -- Debug
  ---------------------------------------------------------------------------
  signal debug : std_logic_vector(7 downto 0);
  signal cnt   : std_logic_vector(24 downto 0);
  
begin

  ---------------------------------------------------------------------------
  -- Clock/Reset
  ---------------------------------------------------------------------------
  System_Clock_inst : system_clock
    port map (
      clk_in1_p => sysclk_p,
      clk_in1_n => sysclk_n,
      clk_out1  => clk_200,
      clk_out2  => clk_125,
      reset     => cpu_rst,
      locked    => clk_loc);

  ADC_Clock_inst : adc_clock
    port map (
      clk_in1_p => clk_ab_p,
      clk_in1_n => clk_ab_n,
      clk_out1  => clk_adc,
      reset     => cpu_rst,
      locked    => adc_loc);

  RSFF_CPU_Reset : rs_ff
    port map (
      r  => cpu_reset,
      s  => "not"(cpu_reset),
      q  => open,
      qb => cpu_rst);

  System_Reset : process(clk_200)
  begin
    if rising_edge(clk_200) then
      sys_rst <= not clk_loc;
    end if;
  end process;

  ADC_Reset : process(clk_adc)
  begin
    if rising_edge(clk_adc) then
      adc_rst <= not adc_loc;
    end if;
  end process;

  ---------------------------------------------------------------------------
  -- ADC
  ---------------------------------------------------------------------------
  ADC_inst : adc
    port map (
      clk        => clk_adc,
      rst        => adc_rst,
      cha_p      => cha_p,
      cha_n      => cha_n,
      chb_p      => chb_p,
      chb_n      => chb_n,
      adc_data_a => adc_data_a,
      adc_data_b => adc_data_b);  

  RSFF_ADC_Register_Reset : rs_ff
    port map (
      r  => gpio_sw_c,
      s  => "not"(gpio_sw_c),
      q  => open,
      qb => adc_reset25);

  ---------------------------------------------------------------------------
  -- ADC Snapshot
  ---------------------------------------------------------------------------
  ADC_Snapshot_int : adc_snapshot
    port map (
      clk           => clk_adc,
      rst           => adc_rst,
      en            => adc_ss_trg,
      fmt_busy      => fmt_busy,
      adc_data_a    => adc_data_a,
      adc_data_b    => adc_data_b,
      wr_data_count => wr_data_count,
      dout          => adc_ss_data,
      rd_en         => fmt_en,
      ack           => adc_ss_ack);

  ---------------------------------------------------------------------------
  -- Data Format for SiTCP
  ---------------------------------------------------------------------------
  Formatter_inst : formatter
    generic map (
      d_size => d_size)
    port map (
      clk        => clk_adc,
      rst        => sys_rst,
      ts_rst     => adc_ss_trg,
      en         => fmt_en,
      din        => fmt_din,
      fifo_wr_en => fifo_wr_en,
      busy       => fmt_busy,
      ack        => fmt_ack,
      dout       => fifo_din);

  fmt_din <= adc_ss_data;

  ---------------------------------------------------------------------------
  -- Data transfer to SiTCP
  ---------------------------------------------------------------------------
  Data_Transfer_to_SiTCP_inst : data_transfer_to_sitcp
    port map (
      rst              => sft_rst,
      wr_clk           => clk_adc,
      rd_clk           => clk_200,
      fifo_wr_en       => fifo_wr_en,
      fifo_almost_full => fifo_almost_full,
      tcp_open_ack     => tcp_open_ack,
      tcp_tx_full      => tcp_tx_full,
      din              => fifo_din,
      tcp_txd          => tcp_txd,
      tcp_tx_wr        => tcp_tx_wr,
      wr_data_count    => wr_data_count);

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
      req       => rbcp_mdl_req,
      ack       => rbcp_mdl_ack,
      rxd       => rbcp_mdl_rxd,
      spi_txd   => spi_txd,
      sft_rst   => open);

  rbcp_id <= rbcp_addr(31 downto 28);   -- Control module ID
                                        --
                                        -- x"0": N/A
                                        -- x"1": ADC Register
                                        -- x"2": DAC Register
                                        -- x"3": ADC Snapshot
                                        -- x"4": Set Frequency
                                        --

  spi_req    <= rbcp_mdl_req when rbcp_id = x"1" or rbcp_id = x"2" else '0';
  adc_ss_trg <= rbcp_mdl_req when rbcp_id = x"3"                   else '0';
  dds_en     <= rbcp_mdl_req when rbcp_id = x"4"                   else '0';

  sft_rst      <= adc_ss_trg;
  rbcp_mdl_ack <= spi_ack or adc_ss_ack or dds_ack;
  rbcp_mdl_rxd <= spi_rxd;

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

  FED_spi_ack : falling_edge_detector
    port map (
      clk => clk_200,
      d   => spi_busy,
      q   => spi_ack);

  ---------------------------------------------------------------------------
  -- DDS
  ---------------------------------------------------------------------------
  DDS_inst : dds
    port map (
      clk   => clk_200,
      rst   => sys_rst,
      en    => dds_en,
      pinc  => pinc,
      valid => dds_valid,
      cos   => cos,
      sin   => sin,
      busy  => dds_busy,
      ack   => dds_ack);

  ---------------------------------------------------------------------------
  -- GPIO LED
  ---------------------------------------------------------------------------
--  gpio_led(0) <= gmii_1000m;
--  gpio_led(1) <= tcp_tx_full;

  ---------------------------------------------------------------------------
  -- GPIO Dip Switch
  ---------------------------------------------------------------------------
  gmii_1000m <= gpio_dip_sw(0);         -- (0: 100MbE, 1: GbE)

  ---------------------------------------------------------------------------
  -- Debug
  ---------------------------------------------------------------------------
  gpio_led <= adc_data_a(13 downto 6) when gpio_dip_sw(3) = '0' else
              adc_data_b(13 downto 6);  -- ADC

  process(clk_adc)
  begin
    if (clk_adc'event and clk_adc = '1') then
      if adc_rst = '1' then
        cnt <= (others => '0');
      else
        cnt <= cnt + 1;
      end if;
    end if;
  end process;

  debug(7) <= cnt(24);

end Behavioral;
