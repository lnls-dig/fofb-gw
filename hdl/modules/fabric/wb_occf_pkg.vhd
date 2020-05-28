------------------------------------------------------------------------------
-- Title      : OCC Fabric Wishbone Streaming definitions
-- Project    : Open Communication Controller
------------------------------------------------------------------------------
-- Author     : Lucas Maziero Russo
-- Company    : CNPEM LNLS-DIG
-- Created    : 2020-05-20
-- Platform   : FPGA-generic
-------------------------------------------------------------------------------
-- Description: Definitions for Wishbone OCC fabric protocol
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
-- Based on ideas from Tomasz Wlostowski for the Whitte Rabbit project

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.genram_pkg.all;

package wb_occf_pkg is
  -- Contants
  constant c_OCCF_ADDRESS_WIDTH      : integer := 4;
  constant c_OCCF_DATA_WIDTH         : integer := 128;

  subtype t_occf_address is
    std_logic_vector(c_occf_address_width-1 downto 0);
  subtype t_occf_data is
    std_logic_vector(c_occf_data_width-1 downto 0);
  subtype t_occf_byte_select is
    std_logic_vector((c_occf_data_width/8)-1 downto 0);

  type t_occf_source_out is record
    adr : t_occf_address;
    dat : t_occf_data;
    cyc : std_logic;
    stb : std_logic;
    we  : std_logic;
    sel : t_occf_byte_select;
  end record;

  subtype t_occf_sink_in is t_occf_source_out;

  type t_occf_source_in is record
    ack   : std_logic;
    stall : std_logic;
    err   : std_logic;
    rty   : std_logic;
  end record;

  subtype t_occf_sink_out is t_occf_source_in;

  type t_occf_source_in_array is array (natural range <>) of t_occf_source_in;
  type t_occf_source_out_array is array (natural range <>) of t_occf_source_out;

  subtype t_occf_sink_in_array is t_occf_source_out_array;
  subtype t_occf_sink_out_array is t_occf_source_in_array;

  constant cc_dummy_occf_addr : std_logic_vector(c_occf_address_width-1 downto 0):=
    (others => 'X');
  constant cc_dummy_occf_dat : std_logic_vector(c_occf_data_width-1 downto 0) :=
    (others => 'X');
  constant cc_dummy_occf_sel : std_logic_vector(c_occf_data_width/8-1 downto 0) :=
    (others => 'X');

  constant cc_dummy_src_in : t_occf_source_in :=
    ('0', '0', '0', '0');
  constant cc_dummy_snk_in : t_occf_sink_in :=
    (cc_dummy_occf_addr, cc_dummy_occf_dat, '0', '0', '0', cc_dummy_occf_sel);

  -- Components
  component occf_fwft_fifo
  generic
  (
    g_DATA_WIDTH                             : natural := 64;
    g_SIZE                                   : natural := 64;

    g_WITH_RD_EMPTY                          : boolean := true;
    g_WITH_RD_FULL                           : boolean := false;
    g_WITH_RD_ALMOST_EMPTY                   : boolean := false;
    g_WITH_RD_ALMOST_FULL                    : boolean := false;
    g_WITH_RD_COUNT                          : boolean := false;

    g_WITH_WR_EMPTY                          : boolean := false;
    g_WITH_WR_FULL                           : boolean := true;
    g_WITH_WR_ALMOST_EMPTY                   : boolean := false;
    g_WITH_WR_ALMOST_FULL                    : boolean := false;
    g_WITH_WR_COUNT                          : boolean := false;

    g_WITH_FIFO_INFERRED                     : boolean := false;

    g_ALMOST_EMPTY_THRESHOLD                 : integer;
    g_ALMOST_FULL_THRESHOLD                  : integer;
    g_ASYNC                                  : boolean := true
  );
  port
  (
    -- Write clock
    wr_clk_i                                 : in  std_logic;
    wr_rst_n_i                               : in  std_logic;

    wr_data_i                                : in  std_logic_vector(g_data_width-1 downto 0);
    wr_en_i                                  : in  std_logic;
    wr_full_o                                : out std_logic;
    wr_count_o                               : out std_logic_vector(f_log2_size(g_size)-1 downto 0);
    wr_almost_empty_o                        : out std_logic;
    wr_almost_full_o                         : out std_logic;

    -- Read clock
    rd_clk_i                                 : in  std_logic;
    rd_rst_n_i                               : in  std_logic;

    rd_data_o                                : out std_logic_vector(g_data_width-1 downto 0);
    rd_valid_o                               : out std_logic;
    rd_en_i                                  : in  std_logic;
    rd_empty_o                               : out std_logic;
    rd_count_o                               : out std_logic_vector(f_log2_size(g_size)-1 downto 0);
    rd_almost_empty_o                        : out std_logic;
    rd_almost_full_o                         : out std_logic
  );
  end component;

  component xwb_occf_sink
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
  end component;

  component wb_occf_sink
  generic (
    g_FIFO_DEPTH                             : natural := 8;
    g_WITH_FIFO_INFERRED                     : boolean := true
  );
  port (
    clk_i                                    : in std_logic;
    rst_n_i                                  : in std_logic;

    snk_dat_i                                : in  std_logic_vector(c_OCCF_DATA_WIDTH-1 downto 0);
    snk_adr_i                                : in  std_logic_vector(c_OCCF_ADDRESS_WIDTH-1 downto 0);
    snk_sel_i                                : in  std_logic_vector((c_OCCF_DATA_WIDTH/8)-1 downto 0);
    snk_cyc_i                                : in  std_logic;
    snk_stb_i                                : in  std_logic;
    snk_we_i                                 : in  std_logic;
    snk_stall_o                              : out std_logic;
    snk_ack_o                                : out std_logic;
    snk_err_o                                : out std_logic;
    snk_rty_o                                : out std_logic;

    -- Decoded & buffered fabric
    addr_o                                   : out std_logic_vector(c_OCCF_ADDRESS_WIDTH-1 downto 0);
    data_o                                   : out std_logic_vector(c_OCCF_DATA_WIDTH-1 downto 0);
    dvalid_o                                 : out std_logic;
    sof_o                                    : out std_logic;
    eof_o                                    : out std_logic;
    bytesel_o                                : out std_logic_vector((c_OCCF_DATA_WIDTH/8)-1 downto 0);
    dreq_i                                   : in  std_logic
  );
  end component;

  component xwb_occf_source
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
  end component;

  component wb_occf_source
  generic (
    g_FIFO_DEPTH                             : natural := 8;
    g_WITH_FIFO_INFERRED                     : boolean := true
  );
  port (
    clk_i                                    : in std_logic;
    rst_n_i                                  : in std_logic;

    -- Wishbone Fabric Interface I/O
    src_dat_o                                : out std_logic_vector(c_OCCF_DATA_WIDTH-1 downto 0);
    src_adr_o                                : out std_logic_vector(c_OCCF_ADDRESS_WIDTH-1 downto 0);
    src_sel_o                                : out std_logic_vector((c_OCCF_DATA_WIDTH/8)-1 downto 0);
    src_cyc_o                                : out std_logic;
    src_stb_o                                : out std_logic;
    src_we_o                                 : out std_logic;
    src_stall_i                              : in  std_logic;
    src_ack_i                                : in  std_logic;
    src_err_i                                : in  std_logic;
    src_rty_i                                : in  std_logic;

    -- Decoded & buffered fabric
    addr_i                                   : in  std_logic_vector(c_OCCF_ADDRESS_WIDTH-1 downto 0);
    data_i                                   : in  std_logic_vector(c_OCCF_DATA_WIDTH-1 downto 0);
    dvalid_i                                 : in  std_logic;
    sof_i                                    : in  std_logic;
    eof_i                                    : in  std_logic;
    bytesel_i                                : in  std_logic_vector((c_OCCF_DATA_WIDTH/8)-1 downto 0);
    dreq_o                                   : out std_logic
    );
  end component;

end wb_occf_pkg;

package body wb_occf_pkg is

end wb_occf_pkg;
