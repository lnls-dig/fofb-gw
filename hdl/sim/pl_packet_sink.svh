`ifndef __PL_PACKET_SINK_SVH
`define __PL_PACKET_SINK_SVH

`include "simdrv_defs.svh"
`include "dummy_packet.svh"
`include "if_plain_accessor.svh"

class PLPacketSink extends DummyPacketSink;
    protected CPlainAccessor m_acc;

    function new(CPlainAccessor acc);
        m_acc  = acc;
    endfunction // new

    function int poll();
        return m_acc.poll();
    endfunction // poll

    function int permanent_stall_enable();
        return m_acc.permanent_stall_enable();
    endfunction

    function int permanent_stall_disable();
        return m_acc.permanent_stall_disable();
    endfunction

    task recv(ref DummyPacket pkt, ref int result = _null);
        byte_array_t tmp;
        pl_cycle_t cyc;
        int i, size  = 0, n = 0;

        pkt = new;
        m_acc.get(cyc);

        for(i=0; i<cyc.data.size(); i++)
            size = size + cyc.data[i].size;

        tmp = new[size];

        //      $display("CDS %d size: %d\n", cyc.data.size(), size);

        pkt.size = size;
        for(i=0; i < cyc.data.size(); i++)
        begin
            pl_xfer_t xf  = cyc.data[i];

            tmp[(xf.size*(i+1)-1)-:8] = byte_array_t'(xf.d);
        end
        pkt.deserialize(tmp);

    endtask // recv

endclass // PLPacketSink

`endif
