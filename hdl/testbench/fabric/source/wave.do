onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Testbench
add wave -noupdate /wb_occf_source_tb/sys_clk
add wave -noupdate /wb_occf_source_tb/sys_rstn
add wave -noupdate -divider DUT
add wave -noupdate /wb_occf_source_tb/DUT/clk_i
add wave -noupdate /wb_occf_source_tb/DUT/occf_src
add wave -noupdate /wb_occf_source_tb/DUT/occf_snk
add wave -noupdate /wb_occf_source_tb/DUT/rst_n_i
add wave -noupdate -divider cmp_occf_src
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/addr
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/bytesel
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/clk
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/clk_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/data_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/data_o
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/dreq
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/dvalid
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/sof
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/eof
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/g_addr_width
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/g_data_width
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/last_access_t
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/rst_n
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/rst_n_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/settings
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_src/xf_idle
add wave -noupdate -divider cmp_wb_occf_source
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/g_FIFO_DEPTH
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/g_WITH_FIFO_INFERRED
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/clk_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/rst_n_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/sof_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/eof_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/dvalid_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/addr_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/bytesel_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/data_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/dreq_o
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/src_ack_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/src_adr_o
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/src_cyc_o
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/src_stb_o
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/src_stall_i
add wave -noupdate -radix hexadecimal /wb_occf_source_tb/DUT/cmp_wb_occf_source/src_dat_o
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/src_we_o
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/src_sel_o
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/src_err_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/src_rty_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/src_in
add wave -noupdate /wb_occf_source_tb/DUT/cmp_wb_occf_source/src_out
add wave -noupdate -divider cmp_occf_snk
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/ack
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/adr
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/clk_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/cyc
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/cyc_end
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/cyc_prev
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/cyc_start
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/dat_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/dat_o
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/err
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/first_transaction
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/g_addr_width
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/g_data_width
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/last_access_t
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/permanent_stall
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/rst_n_i
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/rty
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/sel
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/settings
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/stall
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/stb
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/trans_index
add wave -noupdate /wb_occf_source_tb/DUT/cmp_occf_snk/we
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {111628510 fs} 0}
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
WaveRestoreZoom {0 fs} {1048576 ps}
