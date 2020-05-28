------------------------------------------------------------------------------
-- Title      : OCC Fabric Wishbone Source
-- Project    : Open Communication Controller
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2020-05-26
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: A simple WB packet streaming source with builtin FIFO buffer.
-- Outputs a trivial interface (start-of-packet, end-of-packet, data-valid)
-------------------------------------------------------------------------------
-- Copyright (c) 2020 CNPEM
--
-- This source describes open hardware and is licensed under the CERN-OHL-W v2.
--
-- You may redistribute and modify this documentation and make products using
-- it under the terms of the CERN-OHL-W v2 (https:/cern.ch/cern-ohl), or (at
-- your option) any later version. This documentation is distributed WITHOUT
-- ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY
-- QUALITY AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN-OHL-W v2
-- for applicable conditions.
-------------------------------------------------------------------------------
--
-- Based on ideas from Tomasz Wlostowski for the White Rabbit project

library ieee;
use ieee.std_logic_1164.all;

use work.genram_pkg.all;
use work.wb_occf_pkg.all;

entity xwb_occf_source is
  generic (
    g_FIFO_DEPTH                             : natural := 8;
    g_WITH_FIFO_INFERRED                     : boolean := true
  );
  port (
    clk_i                                    : in std_logic;
    rst_n_i                                  : in std_logic;

    -- Wishbone Fabric Interface I/O
    src_i                                    : in  t_occf_source_in;
    src_o                                    : out t_occf_source_out;

    -- Decoded & buffered logic
    addr_i                                   : in  std_logic_vector(c_OCCF_ADDRESS_WIDTH-1 downto 0);
    data_i                                   : in  std_logic_vector(c_OCCF_DATA_WIDTH-1 downto 0);
    dvalid_i                                 : in  std_logic;
    sof_i                                    : in  std_logic;
    eof_i                                    : in  std_logic;
    bytesel_i                                : in  std_logic_vector((c_OCCF_DATA_WIDTH/8)-1 downto 0);
    dreq_o                                   : out std_logic
    );

end xwb_occf_source;

architecture rtl of xwb_occf_source is
  -- FIFO ranges and control bits location
  constant c_DATA_LSB                        : natural := 0;
  constant c_DATA_MSB                        : natural := c_DATA_LSB + c_OCCF_DATA_WIDTH - 1;

  constant c_ADDR_LSB                        : natural := c_DATA_MSB + 1;
  constant c_ADDR_MSB                        : natural := c_ADDR_LSB + c_OCCF_ADDRESS_WIDTH -1;

  constant c_VALID_BIT                       : natural := c_ADDR_MSB + 1;

  constant c_SEL_LSB                         : natural := c_VALID_BIT + 1;
  constant c_SEL_MSB                         : natural := c_SEL_LSB + (c_OCCF_DATA_WIDTH/8) - 1;

  constant c_EOF_BIT                         : natural := c_SEL_MSB + 1;
  constant c_SOF_BIT                         : natural := c_EOF_BIT + 1;

  alias c_LOGIC_LSB                          is c_VALID_BIT;
  alias c_LOGIC_MSB                          is c_SOF_BIT;
  constant c_LOGIC_WIDTH                     : integer := c_SOF_BIT - c_VALID_BIT + 1;

  constant c_FIFO_WIDTH                      : integer := c_SOF_BIT - c_DATA_LSB + 1;
  constant c_FIFO_DEPTH                      : integer := g_FIFO_DEPTH;

  constant c_FIFO_ALMOST_FULL_THRES          : natural := g_FIFO_DEPTH-2;
  constant c_FIFO_ALMOST_EMPTY_THRES         : natural := 2;

  -- Signals
  signal cyc_int                             : std_logic;
  signal dreq_int                            : std_logic;
  signal dreq_int_d0                         : std_logic;

  signal fifo_we                             : std_logic;
  signal fifo_almost_full                    : std_logic;
  signal fifo_full                           : std_logic;
  signal fifo_valid_out                      : std_logic;
  signal fifo_empty                          : std_logic;
  signal fifo_rd_en                          : std_logic;
  signal fifo_din                            : std_logic_vector(c_FIFO_WIDTH-1 downto 0);
  signal fifo_dout_reg                       : std_logic_vector(c_FIFO_WIDTH-1 downto 0);
  signal fifo_dout                           : std_logic_vector(c_FIFO_WIDTH-1 downto 0);

  signal pre_sof                             : std_logic;
  signal pre_eof                             : std_logic;
  signal pre_dvalid                          : std_logic;
  signal pre_bytesel                         : std_logic_vector((c_OCCF_DATA_WIDTH/8)-1 downto 0);
  signal pre_addr                            : std_logic_vector(c_OCCF_ADDRESS_WIDTH-1 downto 0);
  signal pre_data                            : std_logic_vector(c_OCCF_DATA_WIDTH-1 downto 0);
  signal post_sof                            : std_logic;
  signal post_eof                            : std_logic;
  signal post_dvalid                         : std_logic;
  signal post_bytesel                        : std_logic_vector((c_OCCF_DATA_WIDTH/8)-1 downto 0);
  signal post_addr                           : std_logic_vector(c_OCCF_ADDRESS_WIDTH-1 downto 0);
  signal post_data                           : std_logic_vector(c_OCCF_DATA_WIDTH-1 downto 0);


begin  -- rtl

  -- Stop requesting more data when fifo is almost full, but only
  -- mask FIFO input when it's actually full.
  dreq_o <= not fifo_almost_full;

  pre_dvalid  <= dvalid_i and not fifo_full;
  pre_data    <= data_i;
  pre_addr    <= addr_i;
  pre_sof     <= sof_i;
  pre_eof     <= eof_i;
  pre_bytesel <= bytesel_i;

  -- FIFO inputs
  fifo_we <= pre_dvalid;
  -- FIFO inputs marshall
  fifo_din(c_DATA_MSB downto c_DATA_LSB)   <= pre_data;
  fifo_din(c_ADDR_MSB downto c_ADDR_LSB)   <= pre_addr;
  fifo_din(c_LOGIC_MSB downto c_LOGIC_LSB) <= pre_sof & pre_eof & pre_bytesel & pre_dvalid;

  cmp_fifo_fwft_fifo : occf_fwft_fifo
  generic map
  (
    g_DATA_WIDTH                             => c_FIFO_WIDTH,
    g_SIZE                                   => c_FIFO_DEPTH,
    g_WITH_RD_ALMOST_EMPTY                   => true,
    g_WITH_WR_ALMOST_EMPTY                   => true,
    g_WITH_RD_ALMOST_FULL                    => true,
    g_WITH_WR_ALMOST_FULL                    => true,
    g_ALMOST_EMPTY_THRESHOLD                 => c_FIFO_ALMOST_EMPTY_THRES,
    g_ALMOST_FULL_THRESHOLD                  => c_FIFO_ALMOST_FULL_THRES,
    g_WITH_WR_COUNT                          => false,
    g_WITH_RD_COUNT                          => false,
    g_WITH_FIFO_INFERRED                     => g_WITH_FIFO_INFERRED,
    g_ASYNC                                  => false
  )
  port map
  (
    -- Write clock
    wr_clk_i                                 => clk_i,
    wr_rst_n_i                               => rst_n_i,

    wr_data_i                                => fifo_din,
    wr_en_i                                  => fifo_we,
    wr_full_o                                => fifo_full,
    wr_count_o                               => open,
    wr_almost_empty_o                        => open,
    wr_almost_full_o                         => fifo_almost_full,

    -- Read clock
    rd_clk_i                                 => clk_i,
    rd_rst_n_i                               => rst_n_i,

    rd_data_o                                => fifo_dout,
    rd_valid_o                               => fifo_valid_out,
    rd_en_i                                  => fifo_rd_en,
    rd_empty_o                               => fifo_empty,
    rd_count_o                               => open
  );

  --FIFO outputs
  fifo_rd_en <= not src_i.stall;

  post_sof     <= fifo_dout(c_SOF_BIT);
  post_eof     <= fifo_dout(c_EOF_BIT);
  post_dvalid  <= fifo_dout(c_VALID_BIT);
  post_bytesel <= fifo_dout(c_SEL_MSB downto c_SEL_LSB);
  post_data    <= fifo_dout(c_DATA_MSB downto c_DATA_LSB);
  post_addr    <= fifo_dout(c_ADDR_MSB downto c_ADDR_LSB);

  p_gen_cyc : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        cyc_int <= '0';
      else
        if(src_i.stall = '0' and fifo_valid_out = '1') then
          -- SOF and SOF signals must be one clock cycle long
          -- and must be asserted at the same clock edge as the valid
          -- signal!
          if(post_sof = '1') then --or post_eof = '1')then
            cyc_int <= '1';
          elsif(post_eof = '1') then
            cyc_int <= '0';
          end if;
        end if;
      end if;
    end if;
  end process;

  src_o.cyc <= cyc_int or post_sof;
  src_o.we  <= '1';
  src_o.stb <= post_dvalid and fifo_valid_out;
  src_o.sel <= post_bytesel;
  src_o.dat <= post_data;
  src_o.adr <= post_addr;

end rtl;
