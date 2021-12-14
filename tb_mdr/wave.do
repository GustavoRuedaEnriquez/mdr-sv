onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_mdr/itf/clk
add wave -noupdate /tb_mdr/itf/op
add wave -noupdate /tb_mdr/itf/data
add wave -noupdate -radix decimal /tb_mdr/itf/result
add wave -noupdate /tb_mdr/itf/remainder
add wave -noupdate /tb_mdr/itf/load
add wave -noupdate /tb_mdr/itf/start
add wave -noupdate /tb_mdr/itf/load_x
add wave -noupdate /tb_mdr/itf/load_y
add wave -noupdate /tb_mdr/itf/error
add wave -noupdate /tb_mdr/itf/ready
add wave -noupdate -divider FSM
add wave -noupdate /tb_mdr/uut/dut/control_unit/current_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {49311 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 252
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
WaveRestoreZoom {1014155546 ps} {1014212866 ps}
