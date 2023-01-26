--! VgaTest.vhd
--! Alexander Horstkötter 10.01.2023

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VgaTest is
    port (
        CLK100MHZ, CPU_RESETN : in std_logic;
        VGA_R, VGA_G, VGA_B   : out unsigned(3 downto 0);
        VGA_HS, VGA_VS        : out std_logic);
end entity;

architecture behavioral of VgaTest is
    component VgaCounter is
        port (
            clk, nrst : in std_logic;
            hcount    : out unsigned(9 downto 0);
            vcount    : out unsigned(9 downto 0));
    end component;

    component Synchronizer is
        port (
            clk, nrst : in std_logic;
            hcount    : in unsigned(9 downto 0);
            vcount    : in unsigned(9 downto 0);

            hsync : out std_logic;
            vsync : out std_logic;

            pixel_x : out unsigned(9 downto 0);
            pixel_y : out unsigned(9 downto 0);
            beam    : out std_logic);
    end component;

    component RenderTest is
        port (
            clk, nrst : in std_logic;
            pixel_x   : in unsigned(9 downto 0);
            pixel_y   : in unsigned(9 downto 0);
            beam      : in std_logic;

            R, G, B : out unsigned(3 downto 0));
    end component;

    signal hcount, vcount : unsigned(9 downto 0);
    signal pixel_x        : unsigned(9 downto 0);
    signal pixel_y        : unsigned(9 downto 0);
    signal beam           : std_logic;
begin
    counter : VgaCounter
    port map(
        clk    => CLK100MHZ,
        nrst   => CPU_RESETN,
        hcount => hcount,
        vcount => vcount);

    sync : Synchronizer
    port map(
        clk     => CLK100MHZ,
        nrst    => CPU_RESETN,
        hcount  => hcount,
        vcount  => vcount,
        hsync   => VGA_HS,
        vsync   => VGA_VS,
        pixel_x => pixel_x,
        pixel_y => pixel_y,
        beam    => beam);

    render : RenderTest
    port map(
        clk     => CLK100MHZ,
        nrst    => CPU_RESETN,
        pixel_x => pixel_x,
        pixel_y => pixel_y,
        beam    => beam,
        R       => VGA_R,
        G       => VGA_G,
        B       => VGA_B);
end architecture;