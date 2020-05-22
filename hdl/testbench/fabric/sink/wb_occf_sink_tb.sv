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

//`define WIRE_WB_SINK(iface, prefix) \
//.prefix``_adr_i(iface``.adr), \
//.prefix``_dat_i(iface``.dat_o), \
//.prefix``_stb_i(iface``.stb), \
//.prefix``_sel_i(iface``.sel), \
//.prefix``_cyc_i(iface``.cyc), \
//.prefix``_ack_o(iface``.ack), \
//.prefix``_err_o(iface``.err), \
//.prefix``_stall_o(iface``.stall)
//
//`define WIRE_WB_SOURCE(iface, prefix) \
//.prefix``_adr_o(iface``.adr), \
//.prefix``_dat_o(iface``.dat_i), \
//.prefix``_stb_o(iface``.stb), \
//.prefix``_sel_o(iface``.sel), \
//.prefix``_cyc_o(iface``.cyc), \
//.prefix``_ack_i(iface``.ack), \
//.prefix``_err_i(iface``.err), \
//.prefix``_stall_i(iface``.stall)
//
//`define WIRE_OCCF_SRC(dst, src) \
//assign dst``_o.cyc = src``.cyc; \
//assign dst``_o.stb = src``.stb; \
//assign dst``_o.adr = src``.adr; \
//assign dst``_o.dat = src``.dat_o; \
//assign dst``_o.sel = src``.sel; \
//assign src``.ack = dst``_i.ack; \
//assign src``.err = dst``_i.err; \
//assign src``.stall = dst``_i.stall;
//
//`define WIRE_OCCF_SRC_I(dst, src, i) \
//assign dst``_o[i].cyc = src``.cyc; \
//assign dst``_o[i].stb = src``.stb; \
//assign dst``_o[i].adr = src``.adr; \
//assign dst``_o[i].dat = src``.dat_o; \
//assign dst``_o[i].sel = src``.sel; \
//assign src``.ack = dst``_i[i].ack; \
//assign src``.err = dst``_i[i].err; \
//assign src``.stall = dst``_i[i].stall;
//
//`define WIRE_OCCF_SNK(dst, src) \
//assign dst``.cyc = src``_i.cyc; \
//assign dst``.stb = src``_i.stb; \
//assign dst``.adr = src``_i.adr; \
//assign dst``.dat_i = src``_i.dat; \
//assign dst``.sel = src``_i.sel; \
//assign src``_o.ack = dst``.ack; \
//assign src``_o.err = dst``.err; \
//assign src``_o.stall = dst``.stall;
//
//`define WIRE_OCCF_SNK_I(dst, src, i) \
//assign dst``.cyc = src``_i[i].cyc; \
//assign dst``.stb = src``_i[i].stb; \
//assign dst``.adr = src``_i[i].adr; \
//assign dst``.dat_i = src``_i[i].dat; \
//assign dst``.sel = src``_i[i].sel; \
//assign src``_o[i].ack = dst``.ack; \
//assign src``_o[i].err = dst``.err; \
//assign src``_o[i].stall = dst``.stall;

module wb_occf_sink_svwrap (
    input clk_i,
    input rst_n_i
);

    IWishboneMaster #(
        .g_addr_width(4),
        .g_data_width(128)
    ) cmp_occf_src (
        clk_sys_i,
        rst_n_i
    );

    //IWishboneSlave #(
    //    .g_addr_width(4),
    //    .g_data_width(128)
    //) cmp_occf_snk (
    //    clk_sys_i,
    //    rst_n_i
    //);

    //t_occf_source_out occf_src_o;
    //t_occf_source_in  occf_src_i;
    //t_occf_sink_out   occf_snk_o;
    //t_occf_sink_in    occf_snk_i;

    //`WIRE_OCCF_SNK(cmp_occf_snk, occf_snk);

    //`WIRE_OCCF_SRC(occf_src, cmp_occf_src);
    //assign occ_snk_i = occ_src_o;
    //assign occ_snk_o = occ_src_i;

    wire [127:0] data;
    wire [3:0] addr;
    wire [15:0] bytesel;
    wire dvalid;
    wire sof;
    wire eof;
    wire dreq;

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
    //WBPacketSink occf_snk;

    initial begin
        @(posedge rst_n_i);
        @(posedge clk_i);

        occf_src  = new(cmp_occf_src.get_accessor());
        //occf_snk  = new(cmp_occf_snk.get_accessor());

        cmp_occf_src.settings.cyc_on_stall = 1;
    end

endmodule // wb_occf_sink_svwrap

module wb_occf_sink_tb;

    //------------
    // Parameters
    //------------
    localparam SIMULATION_TIME = 150000;            // [ns]

    //---------
    // Signals
    //---------
    wire sys_clk;
    wire sys_rstn;

    clk_rst cmp_clk_rst(
        .clk_sys_o         (sys_clk),
        .sys_rstn_o        (sys_rstn)
    );

    //-------------------------------
    // Resets and Simulation control
    //------------------------------
    initial begin
        #(SIMULATION_TIME);
        $finish;
    end

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
        gen.set_size(4, 16);

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
