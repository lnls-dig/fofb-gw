onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Testbench
add wave -noupdate /wb_occf_sink_tb/sys_clk
add wave -noupdate /wb_occf_sink_tb/sys_rstn
add wave -noupdate -divider DUT
add wave -noupdate /wb_occf_sink_tb/DUT/addr
add wave -noupdate /wb_occf_sink_tb/DUT/bytesel
add wave -noupdate /wb_occf_sink_tb/DUT/clk_i
add wave -noupdate /wb_occf_sink_tb/DUT/data
add wave -noupdate /wb_occf_sink_tb/DUT/dreq
add wave -noupdate /wb_occf_sink_tb/DUT/dvalid
add wave -noupdate /wb_occf_sink_tb/DUT/eof
add wave -noupdate /wb_occf_sink_tb/DUT/occf_src
add wave -noupdate /wb_occf_sink_tb/DUT/rst_n_i
add wave -noupdate /wb_occf_sink_tb/DUT/sof
add wave -noupdate -divider cmp_occf_src
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/g_addr_width
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/g_data_width
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/last_access_t
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/rst_n
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/rst_n_i
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/rty
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/sel
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/settings
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/ack
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/ack_cnt_int
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/adr
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/clk
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/clk_i
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/cyc
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/stb
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/dat_i
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/dat_o
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/we
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/err
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/stall
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/xf_idle
add wave -noupdate -divider CIWBMasterAccessor
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/ack
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/ack_cnt_int
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/adr
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/clk
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/clk_i
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/cyc
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/dat_i
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/dat_o
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/err
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/g_addr_width
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/g_data_width
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/last_access_t
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/rst_n
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/rst_n_i
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/rty
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/sel
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/settings
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/stall
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/stb
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/we
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_occf_src/xf_idle
add wave -noupdate -divider cmp_wb_occf_sink
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/g_FIFO_DEPTH
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/g_WITH_FIFO_INFERRED
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/clk_i
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/rst_n_i
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/snk_cyc_i
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/snk_stb_i
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/snk_we_i
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/snk_adr_i
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/snk_sel_i
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/snk_dat_i
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/snk_err_o
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/snk_ack_o
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/snk_rty_o
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/snk_stall_o
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/addr_o
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/dreq_i
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/bytesel_o
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/data_o
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/dvalid_o
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/eof_o
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/sof_o
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/snk_in
add wave -noupdate /wb_occf_sink_tb/DUT/cmp_wb_occf_sink/snk_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1126963351 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 fs} {10500 ns}
