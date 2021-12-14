if [file exists work] {vdel -all}
vlib work
#FIXME[def]: define macros for simulation and path to files 
vlog +define+SIMULATION -f files_tb.f
#vlog +protect -f files_tb.f
#vlog -f files_tb.f
onbreak {resume}
set NoQuitOnFinish 1
vsim -voptargs=+acc work.tb_mdr
do wave.do
run -all 
