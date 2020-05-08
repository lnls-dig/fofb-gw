onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /occ_gtpe2_reset_tb/INITCLK_PERIOD
add wave -noupdate /occ_gtpe2_reset_tb/REFCLK_PERIOD
add wave -noupdate /occ_gtpe2_reset_tb/SIM_TIME
add wave -noupdate /occ_gtpe2_reset_tb/USRCLK_PERIOD
add wave -noupdate /occ_gtpe2_reset_tb/counter_data
add wave -noupdate /occ_gtpe2_reset_tb/fail
add wave -noupdate /occ_gtpe2_reset_tb/gsr
add wave -noupdate /occ_gtpe2_reset_tb/gts
add wave -noupdate /occ_gtpe2_reset_tb/init_clk
add wave -noupdate /occ_gtpe2_reset_tb/init_rst
add wave -noupdate /occ_gtpe2_reset_tb/mgtrefclk
add wave -noupdate /occ_gtpe2_reset_tb/pll_lock
add wave -noupdate /occ_gtpe2_reset_tb/pll_rst
add wave -noupdate /occ_gtpe2_reset_tb/rxbufstatus
add wave -noupdate /occ_gtpe2_reset_tb/rxbyterealign
add wave -noupdate /occ_gtpe2_reset_tb/rxcharisk
add wave -noupdate /occ_gtpe2_reset_tb/rxdata
add wave -noupdate /occ_gtpe2_reset_tb/rxdisperr
add wave -noupdate /occ_gtpe2_reset_tb/rxencommaalign
add wave -noupdate /occ_gtpe2_reset_tb/rxnotintable
add wave -noupdate /occ_gtpe2_reset_tb/rxreset
add wave -noupdate /occ_gtpe2_reset_tb/rxresetdone
add wave -noupdate /occ_gtpe2_reset_tb/rxtxn
add wave -noupdate /occ_gtpe2_reset_tb/rxtxp
add wave -noupdate /occ_gtpe2_reset_tb/rxuserrdy
add wave -noupdate /occ_gtpe2_reset_tb/txcharisk
add wave -noupdate /occ_gtpe2_reset_tb/txdata
add wave -noupdate /occ_gtpe2_reset_tb/txreset
add wave -noupdate /occ_gtpe2_reset_tb/txresetdone
add wave -noupdate /occ_gtpe2_reset_tb/txuserrdy
add wave -noupdate /occ_gtpe2_reset_tb/usrclk
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 fs} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {0 fs} {754 fs}
