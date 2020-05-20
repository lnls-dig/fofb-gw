onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clocks}
add wave -noupdate /main/refclkp0
add wave -noupdate /main/refclkp1
add wave -noupdate /main/tx_clk0
add wave -noupdate /main/tx_clk1
add wave -noupdate -divider {Reset Sequence}
add wave -noupdate /main/pll_rst0
add wave -noupdate /main/pll_rst1
add wave -noupdate /main/rx_rdy0
add wave -noupdate /main/rx_rdy1
add wave -noupdate /main/tx_rdy0
add wave -noupdate /main/tx_rdy1
add wave -noupdate -divider {Comma Alignment}
add wave -noupdate /main/rx_resync0
add wave -noupdate /main/rx_resync1
add wave -noupdate /main/rx_synced0
add wave -noupdate /main/rx_synced1
add wave -noupdate -divider {Data}
add wave -noupdate -radix binary /main/tx_k0
add wave -noupdate -radix binary /main/tx_k1
add wave -noupdate -radix hexadecimal /main/tx_data0
add wave -noupdate -radix hexadecimal /main/tx_data1
add wave -noupdate -radix binary /main/rx_k0
add wave -noupdate -radix binary /main/rx_k1
add wave -noupdate -radix hexadecimal /main/rx_data0
add wave -noupdate -radix hexadecimal /main/rx_data1
add wave -noupdate -divider {Error Status}
add wave -noupdate -radix binary /main/rx_buf_err0
add wave -noupdate -radix binary /main/rx_buf_err1
add wave -noupdate -radix binary /main/rx_enc_err0
add wave -noupdate -radix binary /main/rx_enc_err1
add wave -noupdate -divider {Design Validation #0}
add wave -noupdate -radix decimal /main/latency_min0
add wave -noupdate -radix decimal /main/latency_min1
add wave -noupdate -radix decimal /main/latency_max0
add wave -noupdate -radix decimal /main/latency_max1
add wave -noupdate /main/fail0
add wave -noupdate /main/fail1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {3578778135 fs} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 fs} {150000 ns}
