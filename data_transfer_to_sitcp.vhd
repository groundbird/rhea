-----------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2015/04/16 20:28:44
-- Design Name: 
-- Module Name: data_transfer_to_sitcp - Behavioral
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

entity data_transfer_to_sitcp is
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
end entity data_transfer_to_sitcp;

architecture Behavioral of data_transfer_to_sitcp is

  component fifo_generator_0 is
    port (
      rst           : in  std_logic;
      wr_clk        : in  std_logic;
      rd_clk        : in  std_logic;
      din           : in  std_logic_vector(7 downto 0);
      wr_en         : in  std_logic;
      rd_en         : in  std_logic;
      dout          : out std_logic_vector(7 downto 0);
      full          : out std_logic;
      almost_full   : out std_logic;
      wr_ack        : out std_logic;
      overflow      : out std_logic;
      empty         : out std_logic;
      valid         : out std_logic;
      underflow     : out std_logic;
      rd_data_count : out std_logic_vector(16 downto 0);
      wr_data_count : out std_logic_vector(16 downto 0));
  end component fifo_generator_0;

  signal fifo_rd_en       : std_logic;
  signal fifo_full        : std_logic;
  signal fifo_wr_ack      : std_logic;
  signal fifo_overflow    : std_logic;
  signal fifo_empty       : std_logic;
  signal fifo_valid       : std_logic;
  signal fifo_underflow   : std_logic;
  signal fifo_rd_data_cnt : std_logic_vector(16 downto 0);
  signal fifo_wr_data_cnt : std_logic_vector(16 downto 0);

begin
  
  AsynchroFIFO_128KB_for_Data_Transfer_to_SiTCP : fifo_generator_0
    port map (
      rst           => rst,
      wr_clk        => wr_clk,
      rd_clk        => rd_clk,
      din           => din,
      wr_en         => fifo_wr_en,
      rd_en         => fifo_rd_en,
      dout          => tcp_txd,
      full          => fifo_full,
      almost_full   => fifo_almost_full,
      wr_ack        => fifo_wr_ack,
      overflow      => fifo_overflow,
      empty         => fifo_empty,
      valid         => fifo_valid,
      underflow     => fifo_underflow,
      rd_data_count => fifo_rd_data_cnt,
      wr_data_count => fifo_wr_data_cnt);

  fifo_rd_en <= tcp_open_ack when (tcp_tx_full = '0' and fifo_empty = '0') else '0';
  tcp_tx_wr  <= fifo_valid and fifo_rd_en;
  
end architecture Behavioral;
