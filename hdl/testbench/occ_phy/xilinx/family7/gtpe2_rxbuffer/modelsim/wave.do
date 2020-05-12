onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Clocks
add wave -noupdate /main/refclk
add wave -noupdate /main/usrclk
add wave -noupdate -divider {Reset Sequence}
add wave -noupdate /main/pll_rst
add wave -noupdate /main/pll_lock
add wave -noupdate /main/rxreset
add wave -noupdate /main/txreset
add wave -noupdate /main/rxuserrdy
add wave -noupdate /main/txuserrdy
add wave -noupdate /main/rxresetdone
add wave -noupdate /main/txresetdone
add wave -noupdate /main/rdy
add wave -noupdate -divider {Comma Alignment}
add wave -noupdate /main/rxencommaalign
add wave -noupdate /main/rxbyteisaligned
add wave -noupdate -divider Data
add wave -noupdate -radix binary /main/txcharisk
add wave -noupdate -radix hexadecimal /main/txdata
add wave -noupdate -radix binary -childformat {{{/main/rxcharisk[1]} -radix hexadecimal} {{/main/rxcharisk[0]} -radix hexadecimal}} -subitemconfig {{/main/rxcharisk[1]} {-height 17 -radix hexadecimal} {/main/rxcharisk[0]} {-height 17 -radix hexadecimal}} /main/rxcharisk
add wave -noupdate -radix hexadecimal /main/rxdata
add wave -noupdate -divider {Error Status}
add wave -noupdate -radix binary /main/rxbufstatus
add wave -noupdate -radix binary /main/rxdisperr
add wave -noupdate -radix binary /main/rxnotintable
add wave -noupdate -divider {Design Validation}
add wave -noupdate -radix decimal /main/cnt_tries
add wave -noupdate -radix decimal /main/latency_min
add wave -noupdate -radix decimal /main/latency_max
add wave -noupdate /main/fail
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
WaveRestoreZoom {0 fs} {21 us}
