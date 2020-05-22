`ifndef SIMDRV_DEFS_SV
`define SIMDRV_DEFS_SV 1

typedef longint unsigned uint64_t;
typedef int unsigned uint32_t;
typedef shortint unsigned uint16_t;

typedef uint64_t u64_array_t[];
typedef byte byte_array_t[];

`define LARGE_WORD_WIDTH 128
typedef bit [`LARGE_WORD_WIDTH] large_word_t;

typedef large_word_t lword_array_t[];

`define SEL_WORD_WIDTH (`LARGE_WORD_WIDTH/8)
typedef bit [`SEL_WORD_WIDTH] sel_word_t;

typedef sel_word_t sword_array_t[];

virtual class CBusAccessor;
    static int _null  = 0;
    int        m_default_xfer_size;

    task set_default_xfer_size(int default_size);
        m_default_xfer_size = default_size;
    endtask // set_default_xfer_size

    pure virtual task writem(large_word_t addr[], large_word_t data[], input int size, ref int result);
    pure virtual task readm(large_word_t addr[], ref large_word_t data[], input int size, ref int result);

    virtual task read(large_word_t addr, ref large_word_t data, input int size = m_default_xfer_size, ref int result = _null);
        int res;
        large_word_t aa[1], da[];

        da= new[1];

        aa[0]  = addr;
        readm(aa, da, size, res);
        data  = da[0];
    endtask

    virtual task write(large_word_t addr, large_word_t data, input int size = m_default_xfer_size, ref int result = _null);
        large_word_t aa[1], da[1];
        aa[0]  = addr;
        da[0]  = data;
        writem(aa, da, size, result);
    endtask

endclass // CBusAccessor

class CSimUtils;
    static function automatic lword_array_t pack(byte x[], int size, int big_endian = 1);
        lword_array_t tmp;
        int i, j;
        int nwords, nbytes;

        nwords  = (x.size() + size - 1) / size;
        tmp     = new [nwords];

        for(i=0; i<nwords; i++)
        begin
            large_word_t d;
            d         = '{default:0};
            nbytes    = (x.size() - i * nbytes > size ? size : x.size() - i*nbytes);

            for(j=0; j < nbytes; j++)
            begin
                if(big_endian)
                    d[(size-j)*8-1-:8] = x[i*size+j];
                else
                    d[(j+1)*8-1-:8] = x[i*size+j];
            end

            tmp[i] = d;
        end
        return tmp;
    endfunction // pack

    static function automatic byte_array_t unpack(lword_array_t x, int entry_size, int size, int big_endian = 1);
        byte_array_t tmp;
        int i, n;

        tmp  = new[size];
        n    = 0;
        i    = 0;

        while(n < size)
        begin
            tmp[n] = x[i][((n % entry_size) + 1)*8-1-:8];

            n++;
            if(n % entry_size == 0)
                i++;
        end

        return tmp;
    endfunction // unpack

endclass // CSimUtils

static CSimUtils SimUtils;

`endif
