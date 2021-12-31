if [file exists work] {vdel -all}
vlib work
vlog +define+SIMULATION -f files.f
onbreak {resume}
set NoQuitOnFinish 1
vsim -voptargs=+acc work.tb_mdr
log * -r
do wave.do
run 100ms