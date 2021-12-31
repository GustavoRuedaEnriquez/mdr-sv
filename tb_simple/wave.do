onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_mdr/clk
add wave -noupdate -divider INPUT
add wave -noupdate -color Orange /tb_mdr/mdr/start
add wave -noupdate -color Orange /tb_mdr/mdr/load
add wave -noupdate -color Orange -radix decimal /tb_mdr/mdr/data
add wave -noupdate -color Orange /tb_mdr/mdr/op
add wave -noupdate -divider OUTPUT
add wave -noupdate -color Gold /tb_mdr/mdr/ready
add wave -noupdate -color Gold -radix decimal /tb_mdr/mdr/result
add wave -noupdate -color Gold -radix decimal /tb_mdr/mdr/remainder
add wave -noupdate -color Gold /tb_mdr/mdr/load_x
add wave -noupdate -color Gold /tb_mdr/mdr/load_y
add wave -noupdate -color Gold /tb_mdr/mdr/error
add wave -noupdate -divider FSM
add wave -noupdate -color {Spring Green} /tb_mdr/mdr/control_unit/current_state
add wave -noupdate -divider {MUX D}
add wave -noupdate /tb_mdr/mdr/mux_D/i_a
add wave -noupdate /tb_mdr/mdr/mux_D/i_b
add wave -noupdate /tb_mdr/mdr/mux_D/i_sel
add wave -noupdate /tb_mdr/mdr/mux_D/o_sltd
add wave -noupdate -divider OPERAND
add wave -noupdate /tb_mdr/mdr/operands_reg/op_a_in
add wave -noupdate /tb_mdr/mdr/operands_reg/op_b_in
add wave -noupdate /tb_mdr/mdr/operands_reg/op_a_out
add wave -noupdate /tb_mdr/mdr/operands_reg/op_b_out
add wave -noupdate -divider COUNT
add wave -noupdate -color Cyan -radix unsigned /tb_mdr/mdr/counter/count
add wave -noupdate -color Cyan /tb_mdr/mdr/counter/first
add wave -noupdate -color Cyan /tb_mdr/mdr/counter/overflow
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {75 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 223
configure wave -valuecolwidth 87
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
WaveRestoreZoom {73 ps} {90 ps}
