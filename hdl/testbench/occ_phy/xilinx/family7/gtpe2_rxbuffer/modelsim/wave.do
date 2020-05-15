onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clocks #0}
add wave -noupdate /main/refclk0
add wave -noupdate /main/usrclk0
add wave -noupdate -divider {Reset Sequence #0}
add wave -noupdate /main/pll_rst0
add wave -noupdate /main/pll_lock0
add wave -noupdate /main/rxreset0
add wave -noupdate /main/txreset0
add wave -noupdate /main/rxuserrdy0
add wave -noupdate /main/txuserrdy0
add wave -noupdate /main/rxresetdone0
add wave -noupdate /main/txresetdone0
add wave -noupdate /main/rdy0
add wave -noupdate -divider {Comma Alignment #0}
add wave -noupdate /main/rxencommaalign0
add wave -noupdate /main/rxbyteisaligned0
add wave -noupdate -divider {Data #0}
add wave -noupdate -radix binary /main/txcharisk0
add wave -noupdate -radix hexadecimal /main/txdata0
add wave -noupdate -radix binary /main/rxcharisk0
add wave -noupdate -radix hexadecimal /main/rxdata0
add wave -noupdate -divider {Error Status #0}
add wave -noupdate -radix binary /main/rxbufstatus0
add wave -noupdate -radix binary /main/rxdisperr0
add wave -noupdate -radix binary /main/rxnotintable0
add wave -noupdate -divider {Design Validation #0}
add wave -noupdate -radix decimal /main/latency_min0
add wave -noupdate -radix decimal /main/latency_max0
add wave -noupdate /main/fail0
add wave -noupdate -divider {Clocks #1}
add wave -noupdate /main/refclk1
add wave -noupdate /main/usrclk1
add wave -noupdate -divider {Reset Sequence #1}
add wave -noupdate /main/pll_rst1
add wave -noupdate /main/pll_lock1
add wave -noupdate /main/rxreset1
add wave -noupdate /main/txreset1
add wave -noupdate /main/rxuserrdy1
add wave -noupdate /main/txuserrdy1
add wave -noupdate /main/rxresetdone1
add wave -noupdate /main/txresetdone1
add wave -noupdate /main/rdy1
add wave -noupdate -divider {Comma Alignment #1}
add wave -noupdate /main/rxencommaalign1
add wave -noupdate /main/rxbyteisaligned1
add wave -noupdate -divider {Data #1}
add wave -noupdate -radix binary /main/txcharisk1
add wave -noupdate -radix hexadecimal /main/txdata1
add wave -noupdate -radix binary /main/rxcharisk1
add wave -noupdate -radix hexadecimal /main/rxdata1
add wave -noupdate -divider {Error Status #1}
add wave -noupdate -radix binary /main/rxbufstatus1
add wave -noupdate -radix binary /main/rxdisperr1
add wave -noupdate -radix binary /main/rxnotintable1
add wave -noupdate -divider {Design Validation #1}
add wave -noupdate -radix decimal /main/latency_min1
add wave -noupdate -radix decimal /main/latency_max1
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
