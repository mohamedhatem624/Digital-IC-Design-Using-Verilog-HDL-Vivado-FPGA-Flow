vlib work
vlog DSP48A1.v sel_reg.v DSP_TB.v
vsim -voptargs=+acc work.DSP_TB
add wave *
run -all
#quit -sim