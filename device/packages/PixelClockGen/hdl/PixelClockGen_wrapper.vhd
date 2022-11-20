--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
--Date        : Sun Nov 20 01:29:34 2022
--Host        : DESKTOP-M1DSM0F running 64-bit major release  (build 9200)
--Command     : generate_target PixelClockGen_wrapper.bd
--Design      : PixelClockGen_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity PixelClockGen_wrapper is
  port (
    clk100mhz : in STD_LOGIC;
    clk_logic : out STD_LOGIC;
    clk_pixel : out STD_LOGIC;
    locked : out STD_LOGIC;
    reset : in STD_LOGIC
  );
end PixelClockGen_wrapper;

architecture STRUCTURE of PixelClockGen_wrapper is
  component PixelClockGen is
  port (
    clk_logic : out STD_LOGIC;
    clk_pixel : out STD_LOGIC;
    locked : out STD_LOGIC;
    reset : in STD_LOGIC;
    clk100mhz : in STD_LOGIC
  );
  end component PixelClockGen;
begin
PixelClockGen_i: component PixelClockGen
     port map (
      clk100mhz => clk100mhz,
      clk_logic => clk_logic,
      clk_pixel => clk_pixel,
      locked => locked,
      reset => reset
    );
end STRUCTURE;
