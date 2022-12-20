vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xil_defaultlib

vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vcom -work xil_defaultlib  -93 \
"../../../../VgaTerminal.gen/sources_1/ip/I2S_clkgen/I2S_clkgen_sim_netlist.vhdl" \


