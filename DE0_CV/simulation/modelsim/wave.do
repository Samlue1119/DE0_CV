onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {TOP LEVEL INPUTS}
add wave -noupdate -radix unsigned /testbench/clk
add wave -noupdate -radix unsigned /testbench/rst
add wave -noupdate -radix unsigned /testbench/a1/port_b_out
add wave -noupdate -radix unsigned /testbench/w_q
add wave -noupdate -radix unsigned {/testbench/a1/RAM1/ram[37]}
add wave -noupdate -radix hexadecimal /testbench/a1/ir_q
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {210 ps} 0}
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
WaveRestoreZoom {0 ps} {556 ps}
