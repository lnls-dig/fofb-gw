------------------------------------------------------------------------------
-- Title      : OCC Fabric Wishbone Sink
-- Project    : Open Communication Controller
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2020-05-20
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: A simple WB packet streaming sink with builtin FIFO buffer.
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
use ieee.numeric_std.all;

use work.genram_pkg.all;
use work.wb_occf_pkg.all;

entity xwb_occf_sink is
  generic (
    g_FIFO_DEPTH                             : natural := 8;
    g_WITH_FIFO_INFERRED                     : boolean := true
  );
  port (
    clk_i                                    : in std_logic;
    rst_n_i                                  : in std_logic;

    -- Wishbone Fabric Interface I/O
    snk_i                                    : in  t_occf_sink_in;
    snk_o                                    : out t_occf_sink_out;

    -- Decoded & buffered fabric
    addr_o                                   : out std_logic_vector(c_OCCF_ADDRESS_WIDTH-1 downto 0);
    data_o                                   : out std_logic_vector(c_OCCF_DATA_WIDTH-1 downto 0);
    dvalid_o                                 : out std_logic;
    sof_o                                    : out std_logic;
    eof_o                                    : out std_logic;
    bytesel_o                                : out std_logic_vector((c_OCCF_DATA_WIDTH/8)-1 downto 0);
    dreq_i                                   : in  std_logic
    );

end xwb_occf_sink;

architecture rtl of xwb_occf_sink is
  -- FIFO ranges
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

  signal fifo_we                             : std_logic;
  signal fifo_almost_full                    : std_logic;
  signal fifo_valid_out                      : std_logic;
  signal fifo_empty                          : std_logic;
  signal fifo_rd_en                          : std_logic;
  signal fifo_din                            : std_logic_vector(c_FIFO_WIDTH-1 downto 0);
  signal fifo_dout_reg                       : std_logic_vector(c_FIFO_WIDTH-1 downto 0);
  signal fifo_dout                           : std_logic_vector(c_FIFO_WIDTH-1 downto 0);
  signal snk_cyc_d0                          : std_logic;

  signal pre_sof                             : std_logic;
  signal pre_eof                             : std_logic;
  signal pre_dvalid                          : std_logic;
  signal pre_bytesel                         : std_logic_vector((c_OCCF_DATA_WIDTH/8)-1 downto 0);
  signal post_sof                            : std_logic;
  signal post_dvalid                         : std_logic;
  signal post_addr                           : std_logic_vector(c_OCCF_ADDRESS_WIDTH-1 downto 0);
  signal post_data                           : std_logic_vector(c_OCCF_DATA_WIDTH-1 downto 0);
  signal post_eof                            : std_logic;
  signal post_bytesel                        : std_logic_vector((c_OCCF_DATA_WIDTH/8)-1 downto 0);

  signal snk_out                             : t_occf_sink_out;

begin  -- rtl

  p_delay_cyc_and_rd : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        snk_cyc_d0 <= '0';
      else
        if fifo_almost_full = '0' then
          snk_cyc_d0 <= snk_i.cyc;
        end if;
      end if;
    end if;
  end process;

  pre_sof     <= snk_i.cyc and not snk_cyc_d0;  -- sof
  pre_eof     <= not snk_i.cyc and snk_cyc_d0;  -- eof
  pre_bytesel <= snk_i.sel;                 -- bytesel
  pre_dvalid  <= snk_i.stb and snk_i.we and snk_i.cyc and not snk_out.stall;  -- data valid

  snk_out.err   <= '0';
  snk_out.rty   <= '0';

  p_gen_ack_and_stall : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        snk_out.ack <= '0';
        snk_out.stall <= '0';
      else
        snk_out.ack <= pre_dvalid;

        if fifo_almost_full = '1' and pre_dvalid = '1' then
          snk_out.stall <= '1';
        elsif fifo_almost_full = '0' then
          snk_out.stall <= '0';
        end if;

      end if;
    end if;
  end process;

  snk_o <= snk_out;

  -- FIFO inputs
  fifo_we <= pre_dvalid;
  -- FIFO inputs marshall
  fifo_din(c_DATA_MSB downto c_DATA_LSB)   <= snk_i.dat;
  fifo_din(c_ADDR_MSB downto c_ADDR_LSB)   <= snk_i.adr;
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
    wr_full_o                                => open,
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

  p_fifo_reg : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_n_i = '0' then
        fifo_dout_reg <= (others => '0');
      elsif fifo_rd_en = '1' and fifo_valid_out = '1' then
        fifo_dout_reg <= fifo_dout;
      else
        fifo_dout_reg(c_SOF_BIT) <= '0';
        fifo_dout_reg(c_VALID_BIT) <= '0';
        fifo_dout_reg(c_EOF_BIT) <= '0';
      end if;
    end if;
  end process;

  -- FIFO outputs
  fifo_rd_en <= '1' when dreq_i = '1' else '0';

  -- FIFO output unmarshall
  post_sof      <= fifo_dout_reg(c_SOF_BIT); --and q_valid;
  post_dvalid   <= fifo_dout_reg(c_VALID_BIT);
  post_eof      <= fifo_dout_reg(c_EOF_BIT);
  post_bytesel  <= fifo_dout_reg(c_SEL_MSB downto c_SEL_LSB);
  post_data     <= fifo_dout_reg(c_DATA_MSB downto c_DATA_LSB);
  post_addr     <= fifo_dout_reg(c_ADDR_MSB downto c_ADDR_LSB);

  sof_o     <= post_sof ;
  dvalid_o  <= post_dvalid ;
  eof_o     <= post_eof;
  bytesel_o <= post_bytesel;
  data_o    <= post_data;
  addr_o    <= post_addr;

end rtl;
