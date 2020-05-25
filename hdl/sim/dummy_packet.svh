`ifndef __DUMMY_PACKET_SVH
`define __DUMMY_PACKET_SVH

`include "simdrv_defs.svh"

class DummyPacket;

    static  int _zero = 0;

    byte payload[];
    int size;

    task set_size(int size);
        payload  = new[size](payload);
    endtask

    function new(int size = _zero);
        //       size      = 0;
        payload   = new[size](payload);

    endfunction // new

    task deserialize(byte data[]);
        int i, psize;

        psize = data.size();

        if(psize <= 0)
        begin
            return;
        end

        payload = new[psize];

        for(i=0; i < data.size(); i++)
            payload[i]  = data[i];

        size = data.size;
    endtask

    task automatic serialize(ref byte data[]);
        int i;

        data = new[payload.size()](data);

        for (i=0; i < payload.size(); i++)
            data[i]  = payload[i];
    endtask // serialize

    function bit equal(ref DummyPacket b, input int flags = 0);

        if(payload != b.payload)
        begin
            $display("notequal: payload");
            return 0;
        end

        return 1;
    endfunction // equal

    task copy(ref DummyPacket b);

    endtask // copy

    task hexdump(byte buffer []);
        string str;
        int size;
        int i;
        int offset = 0;
        const int per_row = 16;

        size = buffer.size();

        while(size > 0)
        begin
            int n;
            n = (size > per_row ? per_row : size);
            $sformat(str, "+%03x: ", offset);

            for(i=0; i<n; i++)
                $sformat(str, "%s%s%02x", str, (i == (per_row/2)? "-":" "), buffer[offset + i]);
            $display(str);

            offset = offset + n;
            size = size - n;
        end
    endtask // hexdump

    task dump(int full = _zero);
        hexdump(payload);
    endtask // dump

endclass // DummyPacket

class DummyPacketGenerator;

    protected DummyPacket template;
    protected int min_size;
    protected int max_size;
    protected int seed;

    static const int PAYLOAD      = (1<<5);
    static const int SEQ_PAYLOAD  = (1<<7);
    static const int EVEN_LENGTH        = (1<<8);
    static const int POW2_LENGTH        = (1<<9);
    static const int ALL = PAYLOAD | SEQ_PAYLOAD | POW2_LENGTH;

    protected int r_flags;

    function new();
        r_flags             = ALL;
        min_size            = 64;
        max_size            = 128;
        template            = new;
    endfunction // new

    typedef byte dyn_array[];

    protected function dyn_array random_bvec(int size);
        byte v[];
        int i;
        // $display("RandomBVEC %d", size);

        v = new[size](v);
        for(i=0; i < size; i++)
            v[i] = $dist_uniform(seed, 0, 256);

        return v;

    endfunction // random_bvec

    task set_seed(int seed_);
        seed = seed_;
    endtask // set_seed

    function int get_seed();
        return seed;
    endfunction // get_seed

    protected function dyn_array seq_payload(int size);
        byte v[];
        int i;

        v = new[size](v);
        for(i=0; i < size; i++)
            v[i]  = i;

        return v;

    endfunction // random_bvec

    function automatic DummyPacket gen(int set_len = 0);
        DummyPacket pkt;
        int len;

        pkt = new;

        if(set_len > 0)
            len = set_len;
        else
            len = $dist_uniform(seed, min_size, max_size);

        if(r_flags & POW2_LENGTH)
            len = SimUtils.round_down_pow2(len);
        else if((len & 1) && (r_flags & EVEN_LENGTH))
            len++;

        if(r_flags & PAYLOAD)
            pkt.payload = random_bvec(len);
        else if(r_flags & SEQ_PAYLOAD)
            pkt.payload  = seq_payload(len);
        else
            pkt.payload = template.payload;

        pkt.size = len; //payload
        return pkt;

    endfunction

    task set_template(DummyPacket pkt);
        template  = pkt;
    endtask // set_template

    task set_size(int smin, int smax);
        min_size  = smin;
        max_size  = smax;
    endtask // set_size

endclass // DummyPacketGenerator


virtual class DummyPacketSink;

    static int _null  = 0;

    pure virtual function int poll();
    virtual function int permanent_stall_enable(); endfunction
    virtual function int permanent_stall_disable(); endfunction
    pure virtual task recv(ref DummyPacket pkt, ref int result = _null);

endclass // DummyPacketSink

virtual class DummyPacketSource;
    static int _null  = 0;

    pure virtual task send(ref DummyPacket pkt, ref int result = _null);
endclass // PacketSource

`endif
