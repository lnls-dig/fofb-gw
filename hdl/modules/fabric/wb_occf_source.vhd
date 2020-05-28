------------------------------------------------------------------------------
-- Title      : OCC Fabric Wishbone Source Wrapper for Verilog
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

use work.wb_occf_pkg.all;

entity wb_occf_source is
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

end wb_occf_source;

architecture wrapper of wb_occf_source is

  component xwb_occf_source
    generic (
      g_FIFO_DEPTH          : natural := 8;
      g_WITH_FIFO_INFERRED  : boolean := true
    );
    port (
      clk_i                 : in  std_logic;
      rst_n_i               : in  std_logic;
      src_i                 : in  t_occf_source_in;
      src_o                 : out t_occf_source_out;
      addr_i                : in  std_logic_vector(c_OCCF_ADDRESS_WIDTH-1 downto 0);
      data_i                : in  std_logic_vector(c_OCCF_DATA_WIDTH-1 downto 0);
      dvalid_i              : in  std_logic;
      sof_i                 : in  std_logic;
      eof_i                 : in  std_logic;
      bytesel_i             : in  std_logic_vector((c_OCCF_DATA_WIDTH/8)-1 downto 0);
      dreq_o                : out std_logic);
  end component;

  signal src_in  : t_occf_source_in;
  signal src_out : t_occf_source_out;

begin  -- wrapper

  cmp_occf_source_wrapper : xwb_occf_source
    generic map (
      g_FIFO_DEPTH          => g_FIFO_DEPTH,
      g_WITH_FIFO_INFERRED  => g_WITH_FIFO_INFERRED
    )
    port map (
      clk_i     => clk_i,
      rst_n_i   => rst_n_i,
      src_i     => src_in,
      src_o     => src_out,
      addr_i    => addr_i,
      data_i    => data_i,
      dvalid_i  => dvalid_i,
      sof_i     => sof_i,
      eof_i     => eof_i,
      bytesel_i => bytesel_i,
      dreq_o    => dreq_o
    );

  src_cyc_o <= src_out.cyc;
  src_stb_o <= src_out.stb;
  src_we_o  <= src_out.we;
  src_sel_o <= src_out.sel;
  src_adr_o <= src_out.adr;
  src_dat_o <= src_out.dat;

  src_in.rty   <= src_rty_i;
  src_in.err   <= src_err_i;
  src_in.ack   <= src_ack_i;
  src_in.stall <= src_stall_i;


end wrapper;
