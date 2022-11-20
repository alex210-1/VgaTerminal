// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Sun Nov 20 01:30:40 2022
// Host        : DESKTOP-M1DSM0F running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/alexh/Desktop/VHDL/VgaTerminal/device/packages/PixelClockGen/ip/PixelClockGen_clk_wiz_0_0/PixelClockGen_clk_wiz_0_0_stub.v
// Design      : PixelClockGen_clk_wiz_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module PixelClockGen_clk_wiz_0_0(clk_logic, clk_pixel, resetn, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_logic,clk_pixel,resetn,locked,clk_in1" */;
  output clk_logic;
  output clk_pixel;
  input resetn;
  output locked;
  input clk_in1;
endmodule
