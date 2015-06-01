-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/04/24 15:05:28
-- Design Name: 
-- Module Name: data_transfer_to_sitcp_sim - Behavioral
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

entity data_transfer_to_sitcp_sim is
end data_transfer_to_sitcp_sim;

architecture Behavioral of data_transfer_to_sitcp_sim is

  constant clk_period     : time := 5 ns;  -- 200 MHz
  constant clk_period_adc : time := 4 ns;  -- 250 MHz

  signal clk_200 : std_logic;
  signal clk_adc : std_logic;
  signal sys_rst : std_logic;
  signal adc_rst : std_logic;

  component falling_edge_detector is
    port (
      clk : in  std_logic;
      d   : in  std_logic;
      q   : out std_logic);
  end component falling_edge_detector;

  signal spi_ack : std_logic;
  signal fmt_ack : std_logic;

  component adc_snapshot is
    generic (
      ts_size : integer;                -- bytes
      d_cnt   : integer);               -- fmt_data_size*d_cnt bytes
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      trg      : in  std_logic;
      ts       : in  std_logic_vector(ts_size*8-1 downto 0);
      fmt_en   : out std_logic;
      ack      : out std_logic);
  end component adc_snapshot;

  signal adc_ss_ack : std_logic;

  component data_format is
    generic (
      ts_size       : integer;          -- bytes
      fmt_data_size : integer);         -- bytes
    port (
      clk              : in  std_logic;
      rst              : in  std_logic;
      en               : in  std_logic;
      ts               : in  std_logic_vector(ts_size*8-1 downto 0);
      fifo_almost_full : in  std_logic;
--      ts_trg           : out std_logic;
      fifo_wr_en       : out std_logic;
      busy             : out std_logic;
      ack              : out std_logic;
      dout             : out std_logic_vector(7 downto 0));
  end component data_format;

  signal fmt_en    : std_logic;
--  signal ts_trg    : std_logic;
  signal fmt_busy  : std_logic;
  signal fmt_carry : std_logic;
  signal fmt_data  : std_logic_vector(7 downto 0);

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
      tcp_tx_wr        : out std_logic);
  end component data_transfer_to_sitcp;

  signal fifo_wr_en       : std_logic;
  signal fifo_almost_full : std_logic;

  ---------------------------------------------------------------------------
  -- SiTCP signal
  ---------------------------------------------------------------------------
  signal tcp_open_ack : std_logic;
  signal tcp_tx_full  : std_logic;
  signal tcp_txd      : std_logic_vector(7 downto 0);
  signal tcp_tx_wr    : std_logic;

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

  signal rbcp_act     : std_logic;
  signal rbcp_addr    : std_logic_vector(31 downto 0);
  signal rbcp_we      : std_logic;
  signal rbcp_wd      : std_logic_vector(7 downto 0);
  signal rbcp_re      : std_logic;
  signal rbcp_rd      : std_logic_vector(7 downto 0);
  signal rbcp_ack     : std_logic;
  signal rbcp_mdl_req : std_logic;
  signal rbcp_mdl_ack : std_logic;
  signal rbcp_mdl_rxd : std_logic_vector(15 downto 0);
  signal rbcp_id      : std_logic_vector(3 downto 0);
  signal sft_rst      : std_logic;
  signal spi_txd      : std_logic_vector(15 downto 0);
  signal spi_rxd      : std_logic_vector(15 downto 0);

--  component spi_master is
--    generic (
--      slaves  : integer;
--      d_width : integer);
--    port (
--      clk     : in     std_logic;
--      rst     : in     std_logic;
--      trg     : in     std_logic;
--      cpol    : in     std_logic;
--      cpha    : in     std_logic;
--      cont    : in     std_logic;
--      clk_div : in     integer;
--      addr    : in     integer;
--      txd     : in     std_logic_vector(d_width-1 downto 0);
--      miso    : in     std_logic;
--      sclk    : buffer std_logic;
--      ss_n    : buffer std_logic_vector(slaves-1 downto 0);
--      mosi    : out    std_logic;
--      busy    : out    std_logic;
--      rxd     : out    std_logic_vector(d_width-1 downto 0));
--  end component spi_master;

  signal spi_req : std_logic;
--  signal cpol      : std_logic;
--  signal cpha      : std_logic;
--  signal cont      : std_logic;
--  signal clk_div   : integer;
--  signal addr      : integer;
--  signal miso      : std_logic;
--  signal spi_sclk  : std_logic;
--  signal ss_n      : std_logic_vector(slaves-1 downto 0);
--  signal spi_sdata : std_logic;
--  signal busy      : std_logic;
--  signal busy_buf  : std_logic;

  component timestamp is
    generic (
      ts_size : integer);
    port (
      clk  : in     std_logic;
      arst : in     std_logic;
      trg  : in     std_logic;
      ts   : buffer std_logic_vector(ts_size*8-1 downto 0));
  end component timestamp;

  signal ts : std_logic_vector(ts_size*8-1 downto 0);  -- 5 bytes

begin

  ---------------------------------------------------------------------------
  -- Clock
  ---------------------------------------------------------------------------
  Sys_CLK_proc : process
  begin
    clk_200 <= '1';
    wait for clk_period/2;
    clk_200 <= '0';
    wait for clk_period/2;
  end process;

  ADC_CLK_proc : process
  begin
    clk_adc <= '1';
    wait for clk_period_adc/2;
    clk_adc <= '0';
    wait for clk_period_adc/2;
  end process;

  ---------------------------------------------------------------------------
  -- ADC Snapshot
  ---------------------------------------------------------------------------
  ADC_Snapshot_inst : adc_snapshot
    generic map (
      ts_size => ts_size,               -- bytes
      d_cnt   => adc_ss_d_cnt)          -- fmt_data_size*d_cnt bytes
    port map (
      clk      => clk_adc,
      rst      => adc_rst,
      trg      => sft_rst,
      ts       => ts,
      fmt_en   => fmt_en,
      ack      => adc_ss_ack);

  ---------------------------------------------------------------------------
  -- Data Format for SiTCP
  ---------------------------------------------------------------------------
  Data_Format_inst : data_format
    generic map (
      ts_size       => ts_size,         -- bytes
      fmt_data_size => fmt_data_size)   -- bytes
    port map (
      clk              => clk_adc,
      rst              => adc_rst,
      en               => fmt_en,
      ts               => ts,
      fifo_almost_full => fifo_almost_full,
--      ts_trg           => ts_trg,
      fifo_wr_en       => fifo_wr_en,
      busy             => fmt_busy,
      ack              => fmt_ack,
      dout             => fmt_data);

--  FED_fmt_ack : falling_edge_detector
--    port map (
--      clk => clk_adc,
--      d   => fmt_busy,
--      q   => fmt_ack);

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
      din              => fmt_data,
      tcp_txd          => tcp_txd,
      tcp_tx_wr        => tcp_tx_wr);

  ----------------------------------------------------------------------------
  -- RBCP
  ----------------------------------------------------------------------------
  RBCP_inst : rbcp
    generic map (
      d_width => 16)
    port map (
      clk       => clk_200,
      rst       => sys_rst,
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
                                        --

  spi_req <= rbcp_mdl_req when (rbcp_id = x"1" or rbcp_id = x"2") else '0';
  sft_rst <= rbcp_mdl_req when rbcp_id = x"3"                     else '0';

  rbcp_mdl_ack <= spi_ack or sft_rst;
  rbcp_mdl_rxd <= spi_rxd;

  ---------------------------------------------------------------------------
  -- Timestamp
  ---------------------------------------------------------------------------
  Timestamp_inst : timestamp
    generic map (
      ts_size => ts_size)
    port map (
      clk  => clk_adc,
      arst => sft_rst or adc_rst,
      trg  => fmt_ack,
      ts   => ts);

  ---------------------------------------------------------------------------
  -- Stimulus Process (Main)
  ---------------------------------------------------------------------------
  stim_proc : process
  begin
    -- Initialize
    sys_rst <= '1';
    adc_rst <= '1';
    
    tcp_open_ack <= '1';
    tcp_tx_full  <= '0';

    -- RBCP Initialize
    rbcp_act  <= '0';
    rbcp_addr <= (others => '0');
    rbcp_wd   <= (others => '0');
    rbcp_we   <= '0';
    rbcp_re   <= '0';
    spi_ack   <= '0';
    spi_rxd   <= (others => '0');

    wait for clk_period;
    sys_rst <= '0';
    adc_rst <= '0';

    -- Trigger ADC Snapshot Signal
    rbcp_act  <= '1';
    rbcp_addr <= x"30000000";           -- sft_rst <= '1'
    rbcp_wd   <= x"00";
    wait for clk_period*5;
    rbcp_we   <= '1';
    wait for clk_period;
    rbcp_we   <= '0';

--    wait for 5 us;

    -- 2nd sequence
--    rbcp_we <= '1';
--    wait for clk_period;
--    rbcp_we <= '0';

--    wait for 5 us;

    -- 3rd sequence
--    rbcp_we <= '1';
--    wait for clk_period;
--    rbcp_we <= '0';

--    wait for 5 us;

    -- 4th sequence
--    rbcp_we <= '1';
--    wait for clk_period;
--    rbcp_we <= '0';

    wait;
  end process;

end Behavioral;
