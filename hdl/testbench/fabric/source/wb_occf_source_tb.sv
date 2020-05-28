//-----------------------------------------------------------------------------
// Title      : OCC Fabric Source testbench
// Project    : Open Communication Controller
//-----------------------------------------------------------------------------
// Author     : Lucas Russo
// Company    : CNPEM LNLS-DIG
// Created    : 2020-05-26
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

// Simulation timescale
`include "timescale.v"
// Common definitions
`include "defines.v"
// Wishbone stream simulation models
`include "if_wb_master.svh"
`include "if_wb_slave.svh"
`include "if_wb_link.svh"
`include "wb_packet_sink.svh"
`include "wb_packet_source.svh"
// Plain interface simulation models
`include "if_pl_master.svh"
`include "pl_packet_source.svh"

module wb_occf_source_svwrap (
    input clk_i,
    input rst_n_i
);

    IPlainMaster #(
        .g_addr_width(4),
        .g_data_width(128)
    ) cmp_occf_src (
        .clk_i      (clk_i),
        .rst_n_i    (rst_n_i)
    );

    IWishboneSlave #(
        .g_addr_width(4),
        .g_data_width(128)
    ) cmp_occf_snk (
        .clk_i      (clk_i),
        .rst_n_i    (rst_n_i)
    );

    wb_occf_source #(
        .g_FIFO_DEPTH          (8),
        .g_WITH_FIFO_INFERRED  (1'b1)
    )
    cmp_wb_occf_source (
        .clk_i                 (clk_i),
        .rst_n_i               (rst_n_i),

        .src_dat_o             (cmp_occf_snk.dat_i),
        .src_adr_o             (cmp_occf_snk.adr),
        .src_sel_o             (cmp_occf_snk.sel),
        .src_cyc_o             (cmp_occf_snk.cyc),
        .src_stb_o             (cmp_occf_snk.stb),
        .src_we_o              (cmp_occf_snk.we),
        .src_stall_i           (cmp_occf_snk.stall),
        .src_ack_i             (cmp_occf_snk.ack),
        .src_err_i             (cmp_occf_snk.err),
        .src_rty_i             (cmp_occf_snk.rty),

        .addr_i                (cmp_occf_src.addr),
        .data_i                (cmp_occf_src.data_o),
        .dvalid_i              (cmp_occf_src.dvalid),
        .sof_i                 (cmp_occf_src.sof),
        .eof_i                 (cmp_occf_src.eof),
        .bytesel_i             (cmp_occf_src.bytesel),
        .dreq_o                (cmp_occf_src.dreq)
    );

    WBPacketSink occf_snk;
    PLPacketSource occf_src;

    initial begin
        @(posedge rst_n_i);
        @(posedge clk_i);

        occf_snk  = new(cmp_occf_snk.get_accessor());
        occf_src  = new(cmp_occf_src.get_accessor());
    end

endmodule // wb_occf_source_svwrap

module wb_occf_source_tb;

    //------------
    // Parameters
    //------------

    //---------
    // Signals
    //---------
    wire sys_clk;
    wire sys_rstn;

    clk_rst cmp_clk_rst(
        .clk_sys_o         (sys_clk),
        .sys_rstn_o        (sys_rstn)
    );

    // ----
    // DUT
    // ----
    wb_occf_source_svwrap
    DUT (
        .clk_i                 (sys_clk),
        .rst_n_i               (sys_rstn)
    );

    task automatic send_random_packets(PLPacketSource src, ref DummyPacket q[$], input int n_packets);
        DummyPacket pkt, tmpl;
        DummyPacketGenerator gen  = new;
        int i;

        tmpl = new;

        gen.set_template(tmpl);
        gen.set_size(16, 1024);

        for(i=0; i<n_packets; i++)
        begin
            pkt = gen.gen();

            q.push_back(pkt);
            src.send(pkt);
        end
    endtask // send_random_packets

    task automatic test_src(int n_packets);
        int n, n1, n2;
        DummyPacket from_ext[$], pkt;

        n   = 0;
        n1  = 0;
        n2  = 0;

        fork
            send_random_packets(DUT.occf_src, from_ext, n_packets);
        join

        //while(DUT.occf_snk.poll())
        while(from_ext.size() > 0)
        begin
            DummyPacket from_q;

            //DUT.occf_snk.recv(pkt);
            from_q  = from_ext.pop_front();
            n1++;

            $display("Packet %d sent:\n", n1);
            from_q.dump();

        end // while (DUT.ep_snk.poll())
        $display("PASS");

    endtask // test_snk

    initial begin

        @(posedge sys_rstn);
        @(posedge sys_clk);
        test_src(4);

    end

endmodule
