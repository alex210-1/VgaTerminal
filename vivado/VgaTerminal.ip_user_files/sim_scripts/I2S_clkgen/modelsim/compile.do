vlib modelsim_lib/work
vlib modelsim_lib/msim

vlib modelsim_lib/msim/xil_defaultlib

vmap xil_defaultlib modelsim_lib/msim/xil_defaultlib

vcom -work xil_defaultlib  -93 \
"../../../../VgaTerminal.gen/sources_1/ip/I2S_clkgen/I2S_clkgen_sim_netlist.vhdl" \


