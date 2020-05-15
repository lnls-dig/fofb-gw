//-----------------------------------------------------------------------------
// Title      : GTPE2 RX elastic buffer testbench
// Project    : Open Communication Controller
//-----------------------------------------------------------------------------
// Author     : Daniel Tavares
// Company    : CNPEM LNLS-DIG
// Created    : 2020-05-08
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
  localparam IDLE_PERIOD = 193;                   // [usrclk cycles]

  localparam NUM_SUCCESFUL_DATA = 1000;
  localparam IDLE = 16'h95bc;
  localparam IDLE_K = 2'b01;
  localparam SIMULATION = "TRUE";
  localparam SIMULATION_SPEEDUP = "TRUE";

  //---------
  // Signals
  //---------
  reg         refclk0    = 0,       refclk1    = 0;
  reg         pll_rst0   = 0,       pll_rst1   = 0;
  reg         rxreset0   = 0,       rxreset1   = 0;
  reg         txreset0   = 0,       txreset1   = 0;
  reg         rxuserrdy0 = 0,       rxuserrdy1 = 0;
  reg         txuserrdy0 = 0,       txuserrdy1 = 0;
  wire        rxencommaalign0,      rxencommaalign1;
  wire [1:0]  txcharisk0,           txcharisk1;
  wire [15:0] txdata0,              txdata1;
  wire        usrclk0,              usrclk1;
  wire        rxn0, rxp0,           rxn1,rxp1;
  wire        txn0, txp0,           txn1,txp1;
  wire        rxbyterealign0,       rxbyterealign1;
  wire        rxbyteisaligned0,     rxbyteisaligned1;
  wire [1:0]  rxcharisk0,           rxcharisk1;
  wire [1:0]  rxdisperr0,           rxdisperr1;
  wire [1:0]  rxnotintable0,        rxnotintable1;
  wire [2:0]  rxbufstatus0,         rxbufstatus1;
  wire [15:0] rxdata0,              rxdata1;
  wire        rxresetdone0,         rxresetdone1;
  wire        txresetdone0,         txresetdone1;
  wire        pll_lock0,            pll_lock1;
  reg         rdy0,                 rdy1;
  wire        fail0,                fail1;
  
  wire [15:0] latency_min0,         latency_min1;
  wire [15:0] latency_max0,         latency_max1;

  integer     cnt_tries;
  
  //--------
  // Clocks
  //--------
  always begin
    refclk0 = ~refclk0;
    #(REFCLK0_PERIOD/2);
  end
  always begin
    refclk1 = ~refclk1;
    #(REFCLK1_PERIOD/2);
  end

  //-------------------------------
  // Resets and Simulation control
  //------------------------------
  initial begin
    pll_rst0 = 1;
    pll_rst1 = 1;
    #(200*REFCLK0_PERIOD);
    pll_rst0 = 0;
    pll_rst1 = 0;
    #(SIMULATION_TIME - 200*REFCLK0_PERIOD);

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

  //--------------------
  // GTP reset sequence
  //--------------------
  always @(posedge refclk0) begin
    // Pulse GTP reset on rising edge of TX 'user ready' signal, which in turn
    // is asserted once GTP PLL lock has been achieved. RX 'user ready' is only
    // asserted after full TX reset.
    // Note this must be done in refclk domain, not usrclk domain since usrclk
    // is generated by the GTP itself, thus unavailable during reset.
    txuserrdy0 <= pll_lock0;
    txreset0 <= (pll_lock0 ^ txuserrdy0) && pll_lock0;
    rxreset0 <= (pll_lock0 ^ txuserrdy0) && pll_lock0;
    rxuserrdy0 <= txresetdone0;

    rdy0 <= rxuserrdy0 && txuserrdy0 && rxresetdone0 && txresetdone0;
  end

  always @(posedge refclk1) begin
    txuserrdy1 <= pll_lock1;
    txreset1 <= (pll_lock1 ^ txuserrdy1) && pll_lock1;
    rxreset1 <= (pll_lock1 ^ txuserrdy1) && pll_lock1;
    rxuserrdy1 <= txresetdone1;

    rdy1 <= rxuserrdy1 && txuserrdy1 && rxresetdone1 && txresetdone1;
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
    .usrclk_i           (usrclk0),
    .valid_i            (rdy0),
    .rx_data_i          (rxdata0),
    .rx_k_i             (rxcharisk0),
    .tx_data_o          (txdata0),
    .tx_k_o             (txcharisk0),
    .rx_realign_o       (rxencommaalign0),
    .rx_aligned_i       (rxbyteisaligned0),
    .rx_bufstatus_i     (rxbufstatus0),
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
    .usrclk_i           (usrclk1),
    .valid_i            (rdy1),
    .rx_data_i          (rxdata1),
    .rx_k_i             (rxcharisk1),
    .tx_data_o          (txdata1),
    .tx_k_o             (txcharisk1),
    .rx_realign_o       (rxencommaalign1),
    .rx_aligned_i       (rxbyteisaligned1),
    .rx_bufstatus_i     (rxbufstatus1),
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

  occ_gtpe2_tile #(
    .g_SIMULATION           (SIMULATION),
    .g_SIMULATION_SPEEDUP   (SIMULATION_SPEEDUP)
  )
  cmp_occ_gtpe2_tile_0 (
    .rxn_i              (rxn0),
    .rxp_i              (rxp0),
    .txn_o              (txn0),
    .txp_o              (txp0),
    .rxreset_i          (rxreset0),
    .rxresetdone_o      (rxresetdone0),
    .rxcharisk_o        (rxcharisk0),
    .rxdisperr_o        (rxdisperr0),
    .rxnotintable_o     (rxnotintable0),
    .rxbyteisaligned_o  (rxbyteisaligned0),
    .rxbyterealign_o    (rxbyterealign0),
    .rxencommaalign_i   (rxencommaalign0),
    .rxbufstatus_o      (rxbufstatus0),
    .rxdata_o           (rxdata0),
    .rxuserrdy_i        (rxuserrdy0),
    .txreset_i          (txreset0),
    .txresetdone_o      (txresetdone0),
    .txcharisk_i        (txcharisk0),
    .txdata_i           (txdata0),
    .txuserrdy_i        (txuserrdy0),
    .refclk0_i          (refclk0),
    .refclk1_i          (refclk0),
    .usrclk_o           (usrclk0),
    .loopback_i         (3'b000),
    .powerdown_i        (2'b00),
    .pll_lockdetclk_i   (refclk0),
    .pll_lock_o         (pll_lock0),
    .pll_refclklost_o   (),
    .pll_refclksel_i    (3'b001),
    .pll_rst_i          (pll_rst0),
    .init_rst_i         (1'b0),
    .init_clk_i         (refclk0)
  );

  occ_gtpe2_tile #(
    .g_SIMULATION           (SIMULATION),
    .g_SIMULATION_SPEEDUP   (SIMULATION_SPEEDUP)
  )
  cmp_occ_gtpe2_tile_1 (
    .rxn_i              (rxn1),
    .rxp_i              (rxp1),
    .txn_o              (txn1),
    .txp_o              (txp1),
    .rxreset_i          (rxreset1),
    .rxresetdone_o      (rxresetdone1),
    .rxcharisk_o        (rxcharisk1),
    .rxdisperr_o        (rxdisperr1),
    .rxnotintable_o     (rxnotintable1),
    .rxbyteisaligned_o  (rxbyteisaligned1),
    .rxbyterealign_o    (rxbyterealign1),
    .rxencommaalign_i   (rxencommaalign1),
    .rxbufstatus_o      (rxbufstatus1),
    .rxdata_o           (rxdata1),
    .rxuserrdy_i        (rxuserrdy1),
    .txreset_i          (txreset1),
    .txresetdone_o      (txresetdone1),
    .txcharisk_i        (txcharisk1),
    .txdata_i           (txdata1),
    .txuserrdy_i        (txuserrdy1),
    .refclk0_i          (refclk1),
    .refclk1_i          (refclk1),
    .usrclk_o           (usrclk1),
    .loopback_i         (3'b000),
    .powerdown_i        (2'b00),
    .pll_lockdetclk_i   (refclk1),
    .pll_lock_o         (pll_lock1),
    .pll_refclklost_o   (),
    .pll_refclksel_i    (3'b001),
    .pll_rst_i          (pll_rst1),
    .init_rst_i         (1'b0),
    .init_clk_i         (refclk1)
  );

endmodule
