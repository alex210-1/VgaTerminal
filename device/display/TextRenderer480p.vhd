--! resolution and timing from http://tinyvga.com/vga-timing/640x480@60Hz
--! TODO 1080p timings: https://projectf.io/posts/video-timings-vga-720p-1080p/#hd-1920x1080-60-hz

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TextRenderer480p is
    generic (
        TEXT_W : integer := 40;
        TEXT_H : integer := 20);
    port (
        clk100mhz, nrst     : in std_logic;
        s_tvalid            : in std_logic;
        s_taddr             : in integer range 0 to (TEXT_W * TEXT_H) - 1;
        s_tdata             : in std_logic_vector(7 downto 0);
        vga_r, vga_g, vga_b : out std_logic_vector(3 downto 0);
        vga_vs, vga_hs      : out std_logic); --! low active
end entity;

architecture behavioral of TextRenderer480p is
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
            vga_vs, vga_hs      : out std_logic); --! low active
    end component;

    signal clk_count              : unsigned (1 downto 0); -- generate 25MHz pixel clock
    signal vga_vs_pos, vga_hs_pos : std_logic;
    signal clk_en                 : std_logic;
begin
    vga_vs <= not vga_vs_pos;
    vga_hs <= not vga_hs_pos;

    renderer : TextRenderer
    generic map(
        TEXT_W => TEXT_W,
        TEXT_H => TEXT_H,

        -- VGA resolution config for 640 x 480 @ 60 Hz in pixel_clk ticks
        H_VISIBLE     => 640,
        H_FRONT_PORCH => 16,
        H_SYNC_PULSE  => 96,
        H_BACK_PORCH  => 48,

        V_VISIBLE     => 480,
        V_FRONT_PORCH => 10,
        V_SYNC_PULSE  => 2,
        V_BACK_PORCH  => 33)
    port map(
        nrst      => nrst,
        data_clk  => clk100mhz,
        pixel_clk => clk100mhz,
        clk_en    => clk_en,
        s_tvalid  => s_tvalid,
        s_taddr   => s_taddr,
        s_tdata   => s_tdata,
        vga_r     => vga_r,
        vga_g     => vga_g,
        vga_b     => vga_b,
        vga_vs    => vga_vs_pos,
        vga_hs    => vga_hs_pos);

    clk_en <= '1' when clk_count = "00" else '0';

    clk_gen : process (clk100mhz) begin
        if rising_edge(clk100mhz) then
            if nrst = '1' then
                clk_count <= clk_count + 1;
            end if;
        end if;
    end process;

end architecture;