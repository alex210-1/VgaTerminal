-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
-- Date        : Fri Dec  2 22:31:00 2022
-- Host        : DESKTOP-M1DSM0F running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/alexh/Desktop/VHDL/VgaTerminal/vivado/VgaTerminal.gen/sources_1/ip/I2S_clkgen/I2S_clkgen_stub.vhdl
-- Design      : I2S_clkgen
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a100tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity I2S_clkgen is
  Port ( 
    clk_440mhz : out STD_LOGIC;
    resetn : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in : in STD_LOGIC
  );

end I2S_clkgen;

architecture stub of I2S_clkgen is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_440mhz,resetn,locked,clk_in";
begin
end;
