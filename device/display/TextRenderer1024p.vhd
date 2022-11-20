--! resolution and timing from http://tinyvga.com/vga-timing/640x480@60Hz
--! TODO 1080p timings: https://projectf.io/posts/video-timings-vga-720p-1080p/#hd-1920x1080-60-hz

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TextRenderer1024p is
    generic (
        TEXT_W : integer := 80;
        TEXT_H : integer := 42);
    port (
        nrst                 : in std_logic;
        clk100mhz, clk108mhz : in std_logic;
        s_tvalid             : in std_logic;
        s_taddr              : in integer range 0 to (TEXT_W * TEXT_H) - 1;
        s_tdata              : in std_logic_vector(7 downto 0);
        vga_r, vga_g, vga_b  : out std_logic_vector(3 downto 0);
        vga_vs, vga_hs       : out std_logic); --! low active
end entity;

architecture behavioral of TextRenderer1024p is
    component TextRenderer is
        generic (
            TEXT_W : integer;
            TEXT_H : integer;

            H_VISIBLE     : integer;
            H_FRONT_PORCH : integer;
            H_SYNC_PULSE  : integer;
            H_BACK_PORCH  : integer;

            V_VISIBLE     : integer;
            V_FRONT_PORCH : integer;
            V_SYNC_PULSE  : integer;
            V_BACK_PORCH  : integer);
        port (
            nrst                : in std_logic;
            data_clk, pixel_clk : in std_logic;
            clk_en              : in std_logic; --! for use with external clock divider
            s_tvalid            : in std_logic;
            s_taddr             : in integer range 0 to (TEXT_W * TEXT_H) - 1;
            s_tdata             : in std_logic_vector(7 downto 0);
            vga_r, vga_g, vga_b : out std_logic_vector(3 downto 0);
            vga_vs, vga_hs      : out std_logic); --! hs low, vs high active
    end component;
begin
    renderer : TextRenderer
    generic map(
        TEXT_W => TEXT_W,
        TEXT_H => TEXT_H,

        -- VGA resolution config for 1280x1024 @ 60 Hz in pixel_clk ticks
        H_VISIBLE     => 1280,
        H_FRONT_PORCH => 48,
        H_SYNC_PULSE  => 112,
        H_BACK_PORCH  => 248,

        V_VISIBLE     => 1024,
        V_FRONT_PORCH => 1,
        V_SYNC_PULSE  => 3,
        V_BACK_PORCH  => 38)
    port map(
        nrst      => nrst,
        data_clk  => clk100mhz,
        pixel_clk => clk108mhz,
        clk_en    => '1',
        s_tvalid  => s_tvalid,
        s_taddr   => s_taddr,
        s_tdata   => s_tdata,
        vga_r     => vga_r,
        vga_g     => vga_g,
        vga_b     => vga_b,
        vga_vs    => vga_vs,
        vga_hs    => vga_hs);

end architecture;