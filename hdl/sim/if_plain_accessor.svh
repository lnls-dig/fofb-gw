`ifndef IF_PLAIN_ACCESSOR_SV
`define IF_PLAIN_ACCESSOR_SV

`include "if_plain_types.svh"

virtual class CPlainAccessor extends CBusAccessor;

    static int _null  = 0;

    function new();
        m_default_xfer_size = 4;
    endfunction // new

    // [slave only] checks if there are any transactions in the queue
    virtual function automatic int poll();
        return 0;
    endfunction // poll

    // ML stuff [slave only]
    virtual function automatic int  permanent_stall_enable();
        $display("CPlainAccessor: permanent_stall: ON");
        return 0;
    endfunction;

    // ML stuff [slave only]
    virtual function automatic int  permanent_stall_disable();
        $display("CPlainAccessor: permanent_stall: OFF");
        return 0;
    endfunction;

    // [slave only] adds a simulation event (e.g. a forced STALL, RETRY, ERROR)
    // evt = event type (STALL, ERROR, RETRY)
    // behv = event behavior: DELAYED - event occurs after a predefined delay (dly_start)
    //                        RANDOM - event occurs randomly with probability (prob)
    // These two can be combined (random events occuring after a certain initial delay)
    // DELAYED events can be repeated (rep_rate parameter)
    virtual task add_event(pla_sim_event_t evt, pla_sim_behavior_t behv, int dly_start, real prob, int rep_rate);

    endtask // add_event

    // [slave only] gets a cycle from the queue
    virtual task get(ref pl_cycle_t xfer);

    endtask // get

    // [master only] executes a cycle and returns its result
    virtual task put(ref pl_cycle_t xfer);

    endtask // put

    virtual function int idle();
        return 1;
    endfunction // idle

    // [master only] generic write(s), blocking
    virtual task writem(large_word_t addr[], large_word_t data[], int size = 4, ref int result = _null);
        pl_cycle_t cycle;
        int i;

        for(i=0;i < addr.size(); i++)
        begin
            pl_xfer_t xfer;
            xfer.a     = addr[i];
            xfer.d     = data[i];
            xfer.size  = size;
            cycle.data.push_back(xfer);
        end

        //      $display("DS: %d", cycle.data.size());

        put(cycle);
        get(cycle);
        result  = cycle.result;

    endtask // write

    // [master only] generic read(s), blocking
    virtual task readm(large_word_t addr[], ref large_word_t data[], input int size = 4, ref int result = _null);
        pl_cycle_t cycle;
        int i;

        for(i=0;i < addr.size(); i++)
        begin
            pl_xfer_t xfer;
            xfer.a     = addr[i];
            xfer.size  = size;
            cycle.data.push_back(xfer);
        end

        put(cycle);
        get(cycle);

        for(i=0;i < addr.size(); i++)
            data[i]  = cycle.data[i].d;

        result     = cycle.result;

    endtask // readm

    virtual task read(large_word_t addr, ref large_word_t data, input int size = 4, ref int result = _null);
        large_word_t aa[], da[];
        aa     = new[1];
        da     = new[1];
        aa[0]  = addr;
        readm(aa, da, size, result);
        data  = da[0];
    endtask

    virtual task write(large_word_t addr, large_word_t data, int size = 4, ref int result = _null);
        large_word_t aa[], da[];
        aa     = new[1];
        da     = new[1];

        aa[0]  = addr;
        da[0]  = data;
        writem(aa, da, size, result);
    endtask

endclass // CPlainAccessor

`endif //  `ifndef IF_PLAIN_ACCESSOR_SV
