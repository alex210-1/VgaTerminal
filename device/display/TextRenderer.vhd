--! TextRenderer.vhd
--! very basic VGA proof of concept. resolution: 640x480 @60Hz
--! resolution and timing from http://tinyvga.com/vga-timing/640x480@60Hz
--! TODO 1080p timings: https://projectf.io/posts/video-timings-vga-720p-1080p/#hd-1920x1080-60-hz
--! Alexander Horstkötter 07.11.2022
--! framing successfully simulated 07.11.2022
--! Complete refactor, successfully simulated and synthesized 13.11.2022
--! partially works on hardware, but still buggy 13.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fonttable.all;

entity TextRenderer is
    generic (
        TEXT_W : integer := 40;
        TEXT_H : integer := 20);
    port (
        clk, nrst           : in std_logic;
        s_tvalid            : in std_logic;
        s_taddr             : in integer range 0 to (TEXT_W * TEXT_H) - 1;
        s_tdata             : in std_logic_vector(7 downto 0);
        vga_r, vga_g, vga_b : out std_logic_vector(3 downto 0);
        vga_vs, vga_hs      : out std_logic); --! low active
end entity;

architecture behavioral of TextRenderer is
    component ClockDivN is
        generic (
            N : positive);
        port (
            rst    : in std_logic;
            clk    : in std_logic;
            output : out std_logic);
    end component;

    component TextRam is
        generic (
            SIZE : positive := 20 * 40);
        port (
            clk, nrst  : in std_logic;
            write_en   : in std_logic;
            write_addr : in integer range 0 to SIZE - 1;
            write_data : in std_logic_vector(7 downto 0);
            read_addr  : in integer range 0 to SIZE - 1;
            read_data  : out std_logic_vector(7 downto 0));
    end component;

    -- VGA resolution config for 640 x 480 @ 60 Hz in pixel_clk ticks
    constant H_VISIBLE     : integer := 640;
    constant H_FRONT_PORCH : integer := 16;
    constant H_SYNC_PULSE  : integer := 96;
    constant H_BACK_PORCH  : integer := 48;

    constant V_VISIBLE     : integer := 480;
    constant V_FRONT_PORCH : integer := 10;
    constant V_SYNC_PULSE  : integer := 2;
    constant V_BACK_PORCH  : integer := 33;

    constant H_TOTAL : integer := H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;
    constant V_TOTAL : integer := V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;

    signal mono_out  : std_logic;
    signal pixel_clk : std_logic;

    signal horiz_pos  : integer range 0 to H_TOTAL - 1;
    signal verti_pos  : integer range 0 to V_TOTAL - 1;
    signal char_px_x  : integer range 0 to CHAR_WIDTH - 1;
    signal char_px_y  : integer range 0 to CHAR_HEIGHT - 1;
    signal h_read_pos : integer range 0 to TEXT_W - 1;
    signal v_read_pos : integer range 0 to TEXT_H - 1;
    signal cur_char   : std_logic_vector(7 downto 0);
begin
    -- generate pixel clock of 25MHz
    clk_div : ClockDivN
    generic map(
        N => 4)
    port map(
        rst    => not nrst,
        clk    => clk,
        output => pixel_clk);

    text_ram : TextRam
    generic map(
        SIZE => TEXT_W * TEXT_H)
    port map(
        nrst       => nrst,
        clk        => clk,
        write_en   => s_tvalid,
        write_addr => s_taddr,
        write_data => s_tdata,
        -- multiplication by constant should be fine, TODO test synthesis
        read_addr => v_read_pos * TEXT_W + h_read_pos,
        read_data => cur_char);

    -- who needs color anyways? :D
    vga_r <= (others => mono_out);
    vga_g <= (others => mono_out);
    vga_b <= (others => mono_out);

    vga_hs <= '0'
        when horiz_pos > H_VISIBLE + H_FRONT_PORCH
        and horiz_pos <= H_TOTAL - H_BACK_PORCH
        and nrst = '1' else '1';
    vga_vs <= '0'
        when verti_pos > V_VISIBLE + V_FRONT_PORCH
        and verti_pos <= V_TOTAL - V_BACK_PORCH
        and nrst = '1' else '1';

    display_proc : process (clk) begin
        if rising_edge(clk) then
            if nrst = '0' then
                horiz_pos  <= 0;
                verti_pos  <= 0;
                char_px_x  <= 0;
                char_px_y  <= 0;
                h_read_pos <= 0;
                v_read_pos <= 0;
            else
                if pixel_clk = '1' then
                    -- handle horizontal position
                    if horiz_pos < H_TOTAL - 1 then
                        horiz_pos <= horiz_pos + 1;

                        -- visible area
                        if horiz_pos < H_VISIBLE and verti_pos < V_VISIBLE then

                            -- horizontal character pixel counter
                            if h_read_pos < TEXT_W - 1 then -- prevent overflow
                                if char_px_x = CHAR_WIDTH - 1 then
                                    char_px_x  <= 0;
                                    h_read_pos <= h_read_pos + 1;
                                else
                                    char_px_x <= char_px_x + 1;
                                end if;
                            end if;

                            -- video output, function call does not synthesize :(
                            -- mono_out <= ascii_to_pixel(cur_char, char_px_x, char_px_y);
                            if unsigned(cur_char) >= 32 then
                                mono_out <= FONT_TABLE(to_integer(unsigned(cur_char)) - 32)
                                    (char_px_y * CHAR_WIDTH + char_px_x);
                            else
                                -- invalid character
                                mono_out <= '1' when char_px_y mod 2 = char_px_x mod 2 else '0';
                            end if;
                        else
                            mono_out <= '0';
                        end if;
                    else
                        -- end of horizontal scanline
                        horiz_pos  <= 0;
                        h_read_pos <= 0;

                        -- handle vertical position
                        if verti_pos < V_TOTAL - 1 then
                            verti_pos <= verti_pos + 1;

                            -- vertical character pixel counter
                            if char_px_y = CHAR_HEIGHT - 1 then
                                char_px_y <= 0;
                                if v_read_pos < TEXT_H - 1 then -- prevent overflow
                                    v_read_pos <= v_read_pos + 1;
                                end if;
                            else
                                char_px_y <= char_px_y + 1;
                            end if;
                        else
                            verti_pos  <= 0;
                            v_read_pos <= 0;
                            char_px_y  <= 0;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture;