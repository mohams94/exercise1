onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /avalon_mm_sqrt_tb/clk
add wave -noupdate /avalon_mm_sqrt_tb/res_n
add wave -noupdate /avalon_mm_sqrt_tb/write
add wave -noupdate /avalon_mm_sqrt_tb/read
add wave -noupdate /avalon_mm_sqrt_tb/address
add wave -noupdate /avalon_mm_sqrt_tb/writedata
add wave -noupdate /avalon_mm_sqrt_tb/CLK_PERIOD
add wave -noupdate -divider sqrt
add wave -noupdate /avalon_mm_sqrt_tb/uut/fifo_q
add wave -noupdate /avalon_mm_sqrt_tb/uut/sqrt_result
add wave -noupdate /avalon_mm_sqrt_tb/uut/sqrt_input
add wave -noupdate /avalon_mm_sqrt_tb/uut/fifo_empty
add wave -noupdate /avalon_mm_sqrt_tb/uut/fifo_full
add wave -noupdate /avalon_mm_sqrt_tb/uut/fifo_rd
add wave -noupdate /avalon_mm_sqrt_tb/uut/fifo_wr
add wave -noupdate /avalon_mm_sqrt_tb/uut/read_flag
add wave -noupdate -divider fifo
add wave -noupdate /avalon_mm_sqrt_tb/uut/fifo/empty
add wave -noupdate /avalon_mm_sqrt_tb/uut/fifo/full
add wave -noupdate /avalon_mm_sqrt_tb/uut/fifo/q
add wave -noupdate /avalon_mm_sqrt_tb/uut/fifo/scfifo_component/wrreq
add wave -noupdate /avalon_mm_sqrt_tb/uut/fifo/scfifo_component/rdreq
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1 ns}
