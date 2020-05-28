`ifndef __PL_PACKET_SOURCE_SVH
`define __PL_PACKET_SOURCE_SVH

`include "simdrv_defs.svh"
`include "dummy_packet.svh"
`include "if_wishbone_accessor.svh"

class PLPacketSource extends DummyPacketSource;
    protected CPlainAccessor m_acc;

    function new(CPlainAccessor acc);
        m_acc  = acc;
    endfunction // new

    task send(ref DummyPacket pkt, ref int result = _null);
        byte pdata[]; // FIXME: dynamic allocation would be better...
        lword_array_t pdata_p;

        int i, len;
        int xfer_size = `LARGE_WORD_WIDTH / 8;
        int last_xfer_size;

        pl_cycle_t cyc;
        pl_xfer_t xf;

        pkt.serialize(pdata);

        pdata_p = SimUtils.pack(pdata, xfer_size, 1);
        len = pdata_p.size();
        last_xfer_size = pdata.size() % xfer_size;

        for(i=0; i < len; i++)
        begin
            xf.a = '{default:0};

            // last transaction may contain incomplete packets
            if(i==len-1 && (last_xfer_size != 0))
            begin
                xf.size = last_xfer_size;
                xf.d = pdata_p[i] >> (last_xfer_size*8);
            end else begin
                xf.size = xfer_size;
                xf.d = pdata_p[i];
            end

            cyc.data.push_back(xf);
        end

        m_acc.put(cyc);
        m_acc.get(cyc);

        result  = cyc.result;

    endtask // send

endclass // PLPacketSource

`endif
