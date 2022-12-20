// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Fri Dec  2 22:31:00 2022
// Host        : DESKTOP-M1DSM0F running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/alexh/Desktop/VHDL/VgaTerminal/vivado/VgaTerminal.gen/sources_1/ip/I2S_clkgen/I2S_clkgen_stub.v
// Design      : I2S_clkgen
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module I2S_clkgen(clk_440mhz, resetn, locked, clk_in)
/* synthesis syn_black_box black_box_pad_pin="clk_440mhz,resetn,locked,clk_in" */;
  output clk_440mhz;
  input resetn;
  output locked;
  input clk_in;
endmodule
