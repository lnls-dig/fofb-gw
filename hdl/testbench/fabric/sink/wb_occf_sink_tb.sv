//-----------------------------------------------------------------------------
// Title      : OCC Fabric Sink testbench
// Project    : Open Communication Controller
//-----------------------------------------------------------------------------
// Author     : Lucas Russo
// Company    : CNPEM LNLS-DIG
// Created    : 2020-05-20
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
`include "wb_packet_source.svh"
`include "wb_packet_sink.svh"

module wb_occf_sink_svwrap (
    input clk_i,
    input rst_n_i
);

    IWishboneMaster #(
        .g_addr_width(4),
        .g_data_width(128)
    ) cmp_occf_src (
        .clk_i      (clk_i),
        .rst_n_i    (rst_n_i)
    );

    wire [127:0] data;
    wire [3:0] addr;
    wire [15:0] bytesel;
    wire dvalid;
    wire sof;
    wire eof;
    wire dreq = 1'b1;

    wb_occf_sink #(
        .g_FIFO_DEPTH          (8),
        .g_WITH_FIFO_INFERRED  (1'b1)
    )
    cmp_wb_occf_sink (
        .clk_i                 (clk_i),
        .rst_n_i               (rst_n_i),

        .snk_dat_i             (cmp_occf_src.dat_o),
        .snk_adr_i             (cmp_occf_src.adr),
        .snk_sel_i             (cmp_occf_src.sel),
        .snk_cyc_i             (cmp_occf_src.cyc),
        .snk_stb_i             (cmp_occf_src.stb),
        .snk_we_i              (cmp_occf_src.we),
        .snk_stall_o           (cmp_occf_src.stall),
        .snk_ack_o             (cmp_occf_src.ack),
        .snk_err_o             (cmp_occf_src.err),
        .snk_rty_o             (cmp_occf_src.rty),

        .addr_o                (addr),
        .data_o                (data),
        .dvalid_o              (dvalid),
        .sof_o                 (sof),
        .eof_o                 (eof),
        .bytesel_o             (bytesel),
        .dreq_i                (dreq)
    );

    WBPacketSource occf_src;

    initial begin
        @(posedge rst_n_i);
        @(posedge clk_i);

        occf_src  = new(cmp_occf_src.get_accessor());

        cmp_occf_src.settings.cyc_on_stall = 1;
    end

endmodule // wb_occf_sink_svwrap

module wb_occf_sink_tb;

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
    wb_occf_sink_svwrap
    DUT (
        .clk_i                 (sys_clk),
        .rst_n_i               (sys_rstn)
    );

    task automatic send_random_packets(WBPacketSource src, ref DummyPacket q[$], input int n_packets);
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

    task automatic test_snk(int n_packets);
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
        test_snk(4);

    end

endmodule
