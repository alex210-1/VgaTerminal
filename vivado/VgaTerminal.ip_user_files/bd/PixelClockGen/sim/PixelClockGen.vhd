--Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
--Date        : Sun Nov 20 01:29:34 2022
--Host        : DESKTOP-M1DSM0F running 64-bit major release  (build 9200)
--Command     : generate_target PixelClockGen.bd
--Design      : PixelClockGen
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity PixelClockGen is
  port (
    clk100mhz : in STD_LOGIC;
    clk_logic : out STD_LOGIC;
    clk_pixel : out STD_LOGIC;
    locked : out STD_LOGIC;
    reset : in STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of PixelClockGen : entity is "PixelClockGen,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=PixelClockGen,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of PixelClockGen : entity is "PixelClockGen.hwdef";
end PixelClockGen;

architecture STRUCTURE of PixelClockGen is
  component PixelClockGen_clk_wiz_0_0 is
  port (
    resetn : in STD_LOGIC;
    clk_in1 : in STD_LOGIC;
    clk_logic : out STD_LOGIC;
    clk_pixel : out STD_LOGIC;
    locked : out STD_LOGIC
  );
  end component PixelClockGen_clk_wiz_0_0;
  signal clk_wiz_0_clk_logic : STD_LOGIC;
  signal clk_wiz_0_clk_pixel : STD_LOGIC;
  signal clk_wiz_0_locked : STD_LOGIC;
  signal reset_1 : STD_LOGIC;
  signal sys_clock_1 : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of clk100mhz : signal is "xilinx.com:signal:clock:1.0 CLK.CLK100MHZ CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of clk100mhz : signal is "XIL_INTERFACENAME CLK.CLK100MHZ, CLK_DOMAIN PixelClockGen_sys_clock, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
  attribute X_INTERFACE_INFO of clk_logic : signal is "xilinx.com:signal:clock:1.0 CLK.CLK_LOGIC CLK";
  attribute X_INTERFACE_PARAMETER of clk_logic : signal is "XIL_INTERFACENAME CLK.CLK_LOGIC, CLK_DOMAIN /clk_wiz_0_clk_out1, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
  attribute X_INTERFACE_INFO of clk_pixel : signal is "xilinx.com:signal:clock:1.0 CLK.CLK_PIXEL CLK";
  attribute X_INTERFACE_PARAMETER of clk_pixel : signal is "XIL_INTERFACENAME CLK.CLK_PIXEL, CLK_DOMAIN /clk_wiz_0_clk_out1, FREQ_HZ 107954545, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0";
  attribute X_INTERFACE_INFO of reset : signal is "xilinx.com:signal:reset:1.0 RST.RESET RST";
  attribute X_INTERFACE_PARAMETER of reset : signal is "XIL_INTERFACENAME RST.RESET, INSERT_VIP 0, POLARITY ACTIVE_LOW";
begin
  clk_logic <= clk_wiz_0_clk_logic;
  clk_pixel <= clk_wiz_0_clk_pixel;
  locked <= clk_wiz_0_locked;
  reset_1 <= reset;
  sys_clock_1 <= clk100mhz;
clk_wiz_0: component PixelClockGen_clk_wiz_0_0
     port map (
      clk_in1 => sys_clock_1,
      clk_logic => clk_wiz_0_clk_logic,
      clk_pixel => clk_wiz_0_clk_pixel,
      locked => clk_wiz_0_locked,
      resetn => reset_1
    );
end STRUCTURE;
