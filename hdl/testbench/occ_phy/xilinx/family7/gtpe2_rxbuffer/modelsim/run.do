--vlog ../occ_gtpe2_rxbuffer_tb.v +incdir+"." +incdir+../../../../../sim
-- make -f Makefile
-- output log file to file "output.log", set siulation resolution to "fs"
vsim -l output.log \
    +vcd \
    -voptargs="+acc" \
    -t fs \
    +notimingchecks \
    -L unifast_ver \
    -L unisims_ver \
    -L unimacro_ver \
    -L secureip \
    -L xil_defaultlib \
    -L unisims_ver \
    -L unisim \
    -L secureip \
    work.main
do wave.do
log -r /*
set StdArithNoWarnings 1
set NumericStdNoWarnings 1
radix -hexadecimal
run 5000us
wave zoomfull
radix -hexadecimal
