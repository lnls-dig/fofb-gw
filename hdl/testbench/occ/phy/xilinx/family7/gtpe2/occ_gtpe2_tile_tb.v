//-----------------------------------------------------------------------------
// Title      : GTPE2 test bench
// Project    : Open Communication Controller
//-----------------------------------------------------------------------------
// Author     : Daniel Tavares
// Company    : CNPEM LNLS-DIG
// Created    : 2020-05-02
// Platform   : Xilinx
//-----------------------------------------------------------------------------
// Description: Check GTPE2 reset and basic operation.
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

`timescale 1ns / 1ps

module occ_gtpe2_tb;

  //------------
  // Parameters
  //------------
  localparam SIM_TIME = 1000000;
  localparam REFCLK_PERIOD = 8.0;
  localparam USRCLK_PERIOD = REFCLK_PERIOD/2.5;  
  localparam INITCLK_PERIOD = 10.0;

  //--------
  // Clocks
  //--------
  reg mgtrefclk0n = 0;
  reg mgtrefclk0p = 0;
  reg mgtrefclk1n = 0;
  reg mgtrefclk1p = 0;
  always begin
    mgtrefclk0n = ~mgtrefclk0n;
    mgtrefclk0p = ~mgtrefclk0p;
    mgtrefclk1n = ~mgtrefclk1n;
    mgtrefclk1p = ~mgtrefclk1p;
    #(REFCLK_PERIOD/2);
  end

  reg init_clk = 0;
  always begin
    init_clk = ~init_clk;
    #(INITCLK_PERIOD/2);
  end

  //--------
  // Resets
  //--------
  // Simulate global reset that occurs after FPGA configuration
  // Required by Xilinx for realistic transceiver reset simulation
  reg gsr, gts;
  initial
  begin
    gts = 0;
    gsr = 1;
    #(16*REFCLK_PERIOD);
    gsr = 0;
  end

  assign glbl.GSR = gsr;
  assign glbl.GTS = gts;

  reg init_rst;
//  initial
//  begin
//    init_rst = 0;
//    #(0);
//    init_rst = 1;
//    #(INITCLK_PERIOD);
//    init_rst = 0;
//  end

  reg gtpll_rst;
  initial
  begin
    gtpll_rst = 1;
    #(200*INITCLK_PERIOD);
    gtpll_rst = 0;
  end

  reg rxreset, txreset;
  initial
  begin
    rxreset = 0;
    txreset = 0;
    //#(2000*USRCLK_PERIOD);
    #(20000*USRCLK_PERIOD);
    rxreset = 1;
    txreset = 1;
    #(USRCLK_PERIOD);
    rxreset = 0;
    txreset = 0;
  end

  //---------
  // Stimuli
  //---------
  reg rxuserrdy = 1;
  reg txuserrdy = 1;
  reg rxencommaalign;
  initial
  begin
    rxencommaalign = 0;
    #(187500*USRCLK_PERIOD);
    rxencommaalign = 1;
  end

  reg [15:0] counter_data = 0;
  reg [1:0] txcharisk = 2'b10;
  reg [15:0] txdata = 16'hbc95;

  always @(posedge usrclk) begin
    if (counter_data[4:0] == 5'b00000) begin
      txcharisk = 2'b10;
      txdata = 16'hbc95;
    end
    else begin
      txcharisk = 2'b00;
      txdata = counter_data;
    end
    counter_data = counter_data + 1;
  end

  wire usrclk;

  reg fail = 0;
  initial
  begin
     while ($time < SIM_TIME) @(posedge usrclk);

     if (fail)
     begin
        $display("FAIL");
        $stop;
     end
     else
     begin
        $display("PASS");
        $finish;
     end
  end

  // ------------------
  // DUT instantiation
  // ------------------
  wire rxtxn, rxtxp;

  wire rxbyterealign;
  wire [1:0] rxcharisk, rxdisperr, rxnotintable;
  wire [2:0] rxbufstatus;
  wire [15:0] rxdata;
  wire rxresetdone;

  wire txresetdone;

  wire gtpll_locked;
  
  occ_gtpe2_tile #(
    .g_SIM_SPEEDUP    ("FALSE")
  )
  cmp_occ_gtpe2_tile (
    .rxn_i              (rxtxn),
    .rxp_i              (rxtxp),
    .txn_o              (rxtxn),
    .txp_o              (rxtxp),
    .mgtrefclk0n_i      (mgtrefclk0n),
    .mgtrefclk0p_i      (mgtrefclk0p),
    .mgtrefclk1n_i      (mgtrefclk1n),
    .mgtrefclk1p_i      (mgtrefclk1p),
    .rxreset_i          (rxreset),
    .rxresetdone_o      (rxresetdone),
    .rxcharisk_o        (rxcharisk),
    .rxdisperr_o        (rxdisperr),
    .rxnotintable_o     (rxnotintable),
    .rxbyterealign_o    (rxbyterealign),
    .rxencommaalign_i   (rxencommaalign),
    .rxbufstatus_o      (rxbufstatus),
    .rxdata_o           (rxdata),
    .rxuserrdy_i        (rxuserrdy),
    .txreset_i          (txreset),
    .txresetdone_o      (txresetdone),
    .txcharisk_i        (txcharisk),
    .txdata_i           (txdata),
    .txuserrdy_i        (txuserrdy),
    .rxpolarity_i       (1'b0),
    .loopback_i         (3'b000),
    .rxpowerdown_i      (2'b00),
    .txpowerdown_i      (2'b00),
    .gtpll_locked_o     (gtpll_locked),
    .gtpll_refclksel_i  (3'b001),
    .gtpll_rst_i        (gtpll_rst),
    .usrclk_o           (usrclk),
    .gtpll_lockdetclk_i (init_clk),
    .init_rst_i         (init_rst),
    .init_clk_i         (init_clk)
  );

endmodule
