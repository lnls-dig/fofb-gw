//----------------------------------------------------------------------------
// Title      : Software simple packet interface unit for testbenches
// Project    : Open Communication Controller
//----------------------------------------------------------------------------
// Author     : Lucas Maziero Russo
// Company    : CNPEM LNLS-DIG
// Created    : 2020-05-27
// Platform   : FPGA-generic
//-----------------------------------------------------------------------------
// Description: Software simple packet interface unit for testbenches
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

`include "simdrv_defs.svh"
`include "if_plain_types.svh"
`include "if_plain_accessor.svh"

interface IPlainMaster
(
    input clk_i,
    input rst_n_i
);

    parameter g_addr_width     = 32;
    parameter g_data_width     = 32;

    logic [g_addr_width - 1 : 0] addr;
    logic [g_data_width - 1 : 0] data_o;
    logic [(g_data_width/8)-1 : 0] bytesel;
    wire [g_data_width - 1 : 0] data_i;
    logic dvalid;
    logic sof;
    logic eof;
    wire dreq;

    wire clk;
    wire rst_n;

    time last_access_t    = 0;

    struct {
        int gen_random_throttling;
        real throttle_prob;
        int little_endian;
        pl_address_granularity_t addr_gran;
    } settings;

    modport master
    (
        output addr,
        output data_o,
        output bytesel,
        output dvalid,
        output sof,
        output eof,
        input dreq
    );

    function automatic int is_pow2(int xfer_size);
        return (xfer_size != 0) && ((xfer_size & (xfer_size - 1)) == 0);
    endfunction

    function automatic logic[g_addr_width-1:0] gen_addr(large_word_t addr, int xfer_size);
        if (!is_pow2(xfer_size))
            $error("IPl: xfer_size is not power of 2 [%d]\n", xfer_size);

        if(settings.addr_gran == WORD)
            case(g_data_width)
                8: return addr;
                16: return addr >> 1;
                32: return addr >> 2;
                64: return addr >> 3;
                128: return addr >> 4;
                default: $error("IPl: invalid PL data bus width [%d bits]\n", g_data_width);
            endcase // case (xfer_size)
        else
            return addr;
    endfunction

    function automatic logic[63:0] rev_bits(logic [63:0] x, int nbits);
        logic[63:0] tmp;
        int i;

        for (i=0;i<nbits;i++)
            tmp[nbits-1-i]  = x[i];

        return tmp;
    endfunction // rev_bits

    //FIXME: little endian
    function automatic logic[(g_data_width/8)-1:0] gen_sel(large_word_t addr, int xfer_size, int little_endian);
        logic [(g_data_width/8)-1:0] sel;
        const int dbytes  = (g_data_width/8-1);

        if (!is_pow2(xfer_size))
            $error("IPl: xfer_size is not power of 2 [%d\n]", xfer_size);

        sel = ((1<<xfer_size) - 1);

        return rev_bits(sel << (addr & (xfer_size-1)), g_data_width/8);
    endfunction

    function automatic logic[g_data_width-1:0] gen_data(large_word_t addr, large_word_t data, int xfer_size, int little_endian);
        const int dbytes  = (g_data_width/8-1);
        logic[g_data_width-1:0] tmp;

        if (!is_pow2(xfer_size))
            $error("IPl: xfer_size is not power of 2 [%d]\n", xfer_size);

        tmp  = data << (8 * (dbytes - (xfer_size - 1 - (addr & (xfer_size-1)))));

        //      $display("GenData: xs %d dbytes %d %x", tmp, xfer_size, dbytes);

        return tmp;

    endfunction // gen_data

    function automatic large_word_t decode_data(large_word_t addr, logic[g_data_width-1:0] data,  int xfer_size);
        int rem;

        if (!is_pow2(xfer_size))
            $error("IPl: xfer_size is not power of 2 [%d]\n", xfer_size);

        //  $display("decode: a %x d %x xs %x", addr, data ,xfer_size);

        rem  = addr & (xfer_size-1);
        return (data >> (8*rem)) & ((1<<(xfer_size*8)) - 1);
    endfunction // decode_data

    reg xf_idle          = 1;

    task automatic cycle
        (
            ref pl_xfer_t xfer[$],
            input int n_xfers,
            output pl_cycle_result_t result
        );

        int i;
        int failure;
        int cur_rdbk;

        failure = 0;

        xf_idle = 0;
        cur_rdbk = 0;

        if($time != last_access_t)
            @(posedge clk_i); /* resynchronize, just in case */

        while(!dreq) begin
            dvalid <= 1'b0;
            @(posedge clk_i);
        end

        sof <= 1'b1;
        i = 0;

        while(i<n_xfers)
        begin

            if (!dreq || (dreq && settings.gen_random_throttling && SimUtils.probability_hit(settings.throttle_prob))) begin
                dvalid <= 1'b0;
                @(posedge clk_i);

            end else begin
                addr <= gen_addr(xfer[i].a, xfer[i].size);
                dvalid <= 1'b1;
                bytesel <= gen_sel(xfer[i].a, xfer[i].size, settings.little_endian);
                data_o <= gen_data(xfer[i].a, xfer[i].d, xfer[i].size, settings.little_endian);

                // last transaction
                if (i == n_xfers-1)
                    eof <= 1'b1;

                @(posedge clk_i);
                dvalid <= 1'b0;
                sof <= 1'b0;
                eof <= 1'b0;

                i++;
            end

        end // for (i   =0;i<n_xfers;i++)

        xf_idle = 1;
        last_access_t  = $time;
    endtask // automatic

    pl_cycle_t request_queue[$];
    pl_cycle_t result_queue[$];

    class CIPLMasterAccessor extends CPlainAccessor;

        function automatic int poll();
            return 0;
        endfunction

        task get(ref pl_cycle_t xfer);
            while(!result_queue.size())
                @(posedge clk_i);
            xfer  = result_queue.pop_front();
        endtask

        task clear();
        endtask // clear

        task put(ref pl_cycle_t xfer);
            //       $display("PLMaster[%d]: PutCycle",g_data_width);
            request_queue.push_back(xfer);
        endtask // put

        function int idle();
            return (request_queue.size() == 0) && xf_idle;
        endfunction // idle
    endclass // CIPLMasterAccessor


    function CIPLMasterAccessor get_accessor();
        CIPLMasterAccessor tmp;
        tmp  = new;
        return tmp;
    endfunction // get_accessoror

    always@(posedge clk_i)
        if(!rst_n_i)
        begin
            request_queue = {};
            result_queue = {};
            xf_idle = 1;
            addr <= 0;
            data_o <= 0;
            bytesel <= 0;
            dvalid <= 0;
            sof <= 0;
            eof <= 0;
        end

    initial begin
        settings.gen_random_throttling  = 0;
        settings.throttle_prob = 0.1;
        settings.addr_gran = PL_WORD;
    end

    initial forever
    begin
        @(posedge clk_i);

        if(request_queue.size() > 0)
        begin

            pl_cycle_t c;
            pl_cycle_result_t res;

            c = request_queue.pop_front();
            cycle(c.data, c.data.size(), res);
            c.result = res;

            result_queue.push_back(c);
        end
    end

endinterface // IPl
