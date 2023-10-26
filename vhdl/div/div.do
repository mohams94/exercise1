onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ci_div_tb/clk
add wave -noupdate /ci_div_tb/reset
add wave -noupdate /ci_div_tb/n
add wave -noupdate /ci_div_tb/start
add wave -noupdate /ci_div_tb/dataa
add wave -noupdate /ci_div_tb/datab
add wave -noupdate /ci_div_tb/uut/result_wire
add wave -noupdate /ci_div_tb/done
add wave -noupdate -divider Divider
add wave -noupdate /ci_div_tb/uut/done
add wave -noupdate /ci_div_tb/uut/fifo_data
add wave -noupdate /ci_div_tb/uut/result_wire
add wave -noupdate /ci_div_tb/uut/dividend
add wave -noupdate /ci_div_tb/uut/divisor
add wave -noupdate /ci_div_tb/uut/fifo_empty
add wave -noupdate /ci_div_tb/uut/fifo_full
add wave -noupdate /ci_div_tb/uut/fifo_rd
add wave -noupdate /ci_div_tb/uut/fifo_wr
add wave -noupdate /ci_div_tb/uut/fifo_q
add wave -noupdate -radix decimal /ci_div_tb/uut/counter
add wave -noupdate /ci_div_tb/uut/state_0
add wave -noupdate /ci_div_tb/uut/state_1
add wave -noupdate -divider Fifo
add wave -noupdate /ci_div_tb/uut/fifo/data
add wave -noupdate /ci_div_tb/uut/fifo/empty
add wave -noupdate /ci_div_tb/uut/fifo/full
add wave -noupdate /ci_div_tb/uut/fifo/q
add wave -noupdate /ci_div_tb/uut/fifo/scfifo_component/wrreq
add wave -noupdate /ci_div_tb/uut/fifo/scfifo_component/rdreq
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {365385 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 103
configure wave -valuecolwidth 39
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
WaveRestoreZoom {0 ps} {1172841 ps}