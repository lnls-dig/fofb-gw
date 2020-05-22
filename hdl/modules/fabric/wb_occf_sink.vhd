------------------------------------------------------------------------------
-- Title      : OCC Fabric Wishbone Sink Wrapper for Verilog
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

entity wb_occf_sink is
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

end wb_occf_sink;

architecture wrapper of wb_occf_sink is

  component xwb_occf_sink
    generic (
      g_FIFO_DEPTH          : natural := 8;
      g_WITH_FIFO_INFERRED  : boolean := true
    );
    port (
      clk_i                 : in  std_logic;
      rst_n_i               : in  std_logic;
      snk_i                 : in  t_occf_sink_in;
      snk_o                 : out t_occf_sink_out;
      addr_o                : out std_logic_vector(c_OCCF_ADDRESS_WIDTH-1 downto 0);
      data_o                : out std_logic_vector(c_OCCF_DATA_WIDTH-1 downto 0);
      dvalid_o              : out std_logic;
      sof_o                 : out std_logic;
      eof_o                 : out std_logic;
      bytesel_o             : out std_logic_vector((c_OCCF_DATA_WIDTH/8)-1 downto 0);
      dreq_i                : in  std_logic
    );
  end component;

  signal snk_in  : t_occf_sink_in;
  signal snk_out : t_occf_sink_out;

begin  -- wrapper

  cmp_occf_sink_wrapper : xwb_occf_sink
    generic map (
      g_FIFO_DEPTH          => g_FIFO_DEPTH,
      g_WITH_FIFO_INFERRED  => g_WITH_FIFO_INFERRED
    )
    port map (
      clk_i     => clk_i,
      rst_n_i   => rst_n_i,
      snk_i     => snk_in,
      snk_o     => snk_out,
      addr_o    => addr_o,
      data_o    => data_o,
      dvalid_o  => dvalid_o,
      sof_o     => sof_o,
      eof_o     => eof_o,
      bytesel_o => bytesel_o,
      dreq_i    => dreq_i);

  snk_in.adr <= snk_adr_i;
  snk_in.dat <= snk_dat_i;
  snk_in.stb <= snk_stb_i;
  snk_in.we  <= snk_we_i;
  snk_in.cyc <= snk_cyc_i;
  snk_in.sel <= snk_sel_i;

  snk_stall_o <= snk_out.stall;
  snk_ack_o   <= snk_out.ack;
  snk_err_o   <= snk_out.err;
  snk_rty_o   <= snk_out.rty;

end wrapper;
