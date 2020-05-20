//-----------------------------------------------------------------------------
// Title      : GTPE2 RX elastic buffer testbench
// Project    : Open Communication Controller
//-----------------------------------------------------------------------------
// Author     : Daniel Tavares
// Company    : CNPEM LNLS-DIG
// Created    : 2020-05-18
// Platform   : Xilinx
//-----------------------------------------------------------------------------
// Copyright (c) 2020 CNPEM
//
// This source describes open hardware and is licensed under the CERN-OHL-W v2.
//
// You may redistribute and modify this documentation and make products using
// it under the terms of the CERN-OHL-W v2 (https:/cern.ch/cern-ohl), or (at
// your option) any later version. This documentation is distributed WITHOUT
// ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY, SATISFACTORY
// QUALITY AND FITNESS FOR A PARTICULAR PURPOSE. Please see the CERN-OHL-W v2
// for applicable conditions.
//-----------------------------------------------------------------------------

`timescale 1ns / 100fs

`include "latency_checker.v"

module main;

  //------------
  // Parameters
  //------------
  localparam SIMULATION_TIME = 150000;            // [ns]
  localparam REFCLK0_PERIOD = 8.0;                // [ns]
  localparam USRCLK0_PERIOD = REFCLK0_PERIOD/2.5; // [ns]
  localparam REFCLK1_PERIOD = 8.0*(1+1e-4);       // [ns]
  localparam USRCLK1_PERIOD = REFCLK1_PERIOD/2.5; // [ns]

  localparam BLIND_PERIOD = 10;                   // [usrclk cycles]
  localparam IDLE_PERIOD = 13;                    // [usrclk cycles]

  localparam NUM_SUCCESFUL_DATA = 1000;
  localparam IDLE = 16'h95bc;
  localparam IDLE_K = 2'b01;
  localparam SIMULATION = "TRUE";

  //---------
  // Signals
  //---------
  reg         refclkp0 = 0,         refclkp1 = 0;
  reg         refclkn0 = 0,         refclkn1 = 0;
  reg         pll_rst0 = 0,         pll_rst1 = 0;
  wire        rx_rdy0,              rx_rdy1;
  wire        tx_rdy0,              tx_rdy1;

  wire        rx_resync0,           rx_resync1;
  wire        rx_synced0,           rx_synced1;

  wire        tx_clk0,              tx_clk1;
  wire [1:0]  tx_k0,                tx_k1;
  wire [15:0] tx_data0,             tx_data1;
  wire        rx_clk0,              rx_clk1;
  wire [1:0]  rx_k0,                rx_k1;
  wire [15:0] rx_data0,             rx_data1;
  wire        rx_enc_err0,          rx_enc_err1;

  wire        rx_buf_err0,          rx_buf_err1;

  wire        rxn0, rxp0,           rxn1,rxp1;
  wire        txn0, txp0,           txn1,txp1;

  wire        fail0,                fail1;
  wire [15:0] latency_min0,         latency_min1;
  wire [15:0] latency_max0,         latency_max1;

  //--------
  // Clocks
  //--------
  always begin
    refclkp0 = ~refclkp0;
    refclkn0 = ~refclkn0;
    #(REFCLK0_PERIOD/2);
  end
  always begin
    refclkp1 = ~refclkp1;
    refclkn1 = ~refclkn1;
    #(REFCLK1_PERIOD/2);
  end

  //-------------------------------
  // Resets and Simulation control
  //------------------------------
  initial begin
    pll_rst0 = 1;
    pll_rst1 = 1;
    #(REFCLK0_PERIOD);
    pll_rst0 = 0;
    pll_rst1 = 0;
    #(SIMULATION_TIME - REFCLK0_PERIOD);

    if (!fail0 && !fail1) begin
      $display("TX1-RX0 latency [ns]: %d (min) - %d (max).", latency_min0, latency_max0);
      $display("TX0-RX1 latency [ns]: %d (min) - %d (max).", latency_min1, latency_max1);
      $display("PASS");
    end
    else begin
      $display("FAIL");
    end
    $finish;
  end

  //-------------------
  // Design validation
  //-------------------
  latency_checker #
  (
    .g_IDLE                 (IDLE),
    .g_IDLE_K               (IDLE_K),
    .g_IDLE_PERIOD          (IDLE_PERIOD),
    .g_BLIND_PERIOD         (BLIND_PERIOD),
    .g_NUM_SUCCESFUL_DATA   (NUM_SUCCESFUL_DATA)
  )
  cmp_latency_checker_0
  (
    .fail_o             (fail0),
    .tx_clk_i           (tx_clk0),
    .tx_data_o          (tx_data0),
    .tx_k_o             (tx_k0),
    .rx_clk_i           (rx_clk0),
    .rx_data_i          (rx_data0),
    .rx_k_i             (rx_k0),
    .rx_resync_o        (rx_resync0),
    .rx_synced_i        (rx_synced0),
    .rx_buf_err_i       (rx_buf_err0),
    .rx_rdy_i           (rx_rdy0),
    .rx_remote_rdy_i    (rx_rdy1),
    .latency_min_o      (latency_min0),
    .latency_max_o      (latency_max0)
  );

  latency_checker #
  (
    .g_IDLE                 (IDLE),
    .g_IDLE_K               (IDLE_K),
    .g_IDLE_PERIOD          (IDLE_PERIOD),
    .g_BLIND_PERIOD         (BLIND_PERIOD),
    .g_NUM_SUCCESFUL_DATA   (NUM_SUCCESFUL_DATA)
  )
  cmp_latency_checker_1
  (
    .fail_o             (fail1),
    .tx_clk_i           (tx_clk1),
    .tx_data_o          (tx_data1),
    .tx_k_o             (tx_k1),
    .rx_clk_i           (rx_clk1),
    .rx_data_i          (rx_data1),
    .rx_k_i             (rx_k1),
    .rx_resync_o        (rx_resync1),
    .rx_synced_i        (rx_synced1),
    .rx_buf_err_i       (rx_buf_err1),
    .rx_rdy_i           (rx_rdy1),
    .rx_remote_rdy_i    (rx_rdy0),
    .latency_min_o      (latency_min1),
    .latency_max_o      (latency_max1)
  );

  // ----
  // DUT 
  // ----
  assign rxn0 = txn1;
  assign rxp0 = txp1;
  assign rxn1 = txn0;
  assign rxp1 = txp0;

  occ_gtp_phy_family7 #(
    .g_SIMULATION           (SIMULATION)
  )
  occ_gtp_phy_family7_0 (
    .pad_rxn_i          (rxn0),
    .pad_rxp_i          (rxp0),
    .pad_txn_o          (txn0),
    .pad_txp_o          (txp0),
    .pad_refclkn_i      (refclkn0),
    .pad_refclkp_i      (refclkp0),    
    .rst_i              (pll_rst0),
    .tx_rst_i           (1'b0),
    .tx_clk_o           (tx_clk0),
    .tx_data_i          (tx_data0),
    .tx_k_i             (tx_k0),
    .tx_rdy_o           (tx_rdy0),
    .rx_rst_i           (1'b0),
    .rx_clk_o           (rx_clk0),
    .rx_data_o          (rx_data0),
    .rx_k_o             (rx_k0),
    .rx_resync_i        (rx_resync0),
    .rx_synced_o        (rx_synced0),
    .rx_rdy_o           (rx_rdy0),
    .rx_enc_err_o       (rx_enc_err0),
    .rx_buf_err_o       (rx_buf_err0),
    .loopen_i           (3'b000)
  );

  occ_gtp_phy_family7 #(
    .g_SIMULATION           (SIMULATION)
  )
  occ_gtp_phy_family7_1 (
    .pad_rxn_i          (rxn1),
    .pad_rxp_i          (rxp1),
    .pad_txn_o          (txn1),
    .pad_txp_o          (txp1),
    .pad_refclkn_i      (refclkn1),
    .pad_refclkp_i      (refclkp1),    
    .rst_i              (pll_rst1),
    .tx_rst_i           (1'b0),
    .tx_clk_o           (tx_clk1),
    .tx_data_i          (tx_data1),
    .tx_k_i             (tx_k1),
    .tx_rdy_o           (tx_rdy1),
    .rx_rst_i           (1'b0),
    .rx_clk_o           (rx_clk1),
    .rx_data_o          (rx_data1),
    .rx_k_o             (rx_k1),
    .rx_resync_i        (rx_resync1),
    .rx_synced_o        (rx_synced1),
    .rx_rdy_o           (rx_rdy1),
    .rx_enc_err_o       (rx_enc_err1),
    .rx_buf_err_o       (rx_buf_err1),
    .loopen_i           (3'b000)
  );

endmodule
