onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /psoa_sigmoid_tb/sigmoid_taylor_DUT/x
add wave -noupdate /psoa_sigmoid_tb/sigmoid_taylor_DUT/clk
add wave -noupdate /psoa_sigmoid_tb/sigmoid_taylor_DUT/f_x
add wave -noupdate /psoa_sigmoid_tb/sigmoid_taylor_DUT/n
add wave -noupdate /psoa_sigmoid_tb/sigmoid_taylor_DUT/phi
add wave -noupdate /psoa_sigmoid_tb/sigmoid_taylor_DUT/phi_xi
add wave -noupdate /psoa_sigmoid_tb/sigmoid_taylor_DUT/xi
add wave -noupdate /psoa_sigmoid_tb/sigmoid_taylor_DUT/B
add wave -noupdate /psoa_sigmoid_tb/sigmoid_taylor_DUT/D
add wave -noupdate /psoa_sigmoid_tb/sigmoid_taylor_DUT/q
add wave -noupdate /psoa_sigmoid_tb/sigmoid_taylor_DUT/result_mult
add wave -noupdate /psoa_sigmoid_tb/sigmoid_taylor_DUT/W
add wave -noupdate /psoa_sigmoid_tb/sigmoid_taylor_DUT/V
add wave -noupdate /psoa_sigmoid_tb/sigmoid_taylor_DUT/lambda
add wave -noupdate /psoa_sigmoid_tb/sigmoid_taylor_DUT/S
add wave -noupdate /psoa_sigmoid_tb/sigmoid_taylor_DUT/tmp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {39050 ps} {40050 ps}
