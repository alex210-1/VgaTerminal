-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
-- Date        : Sun Nov 20 01:30:40 2022
-- Host        : DESKTOP-M1DSM0F running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/alexh/Desktop/VHDL/VgaTerminal/device/packages/PixelClockGen/ip/PixelClockGen_clk_wiz_0_0/PixelClockGen_clk_wiz_0_0_stub.vhdl
-- Design      : PixelClockGen_clk_wiz_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity PixelClockGen_clk_wiz_0_0 is
  Port ( 
    clk_logic : out STD_LOGIC;
    clk_pixel : out STD_LOGIC;
    resetn : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end PixelClockGen_clk_wiz_0_0;

architecture stub of PixelClockGen_clk_wiz_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_logic,clk_pixel,resetn,locked,clk_in1";
begin
end;
