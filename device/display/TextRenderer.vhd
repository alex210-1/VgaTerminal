--! TextRenderer.vhd
--! very basic VGA proof of concept. resolution: 640x480 @60Hz
--! Alexander Horstkötter 07.11.2022
--! framing successfully simulated 07.11.2022
--! Complete refactor, successfully simulated and synthesized 13.11.2022
--! partially works on hardware, but still buggy 13.11.2022
--! optimzided for synthesis 19.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

entity TextRenderer is
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
        vga_vs, vga_hs      : out std_logic); --! polarity depends on resolution
end entity;

architecture behavioral of TextRenderer is
    component TextRam is
        generic (
            SIZE : positive);
        port (
            nrst       : in std_logic;
            write_clk  : in std_logic;
            write_en   : in std_logic;
            write_addr : in integer range 0 to SIZE - 1;
            write_data : in std_logic_vector(7 downto 0);
            read_clk   : in std_logic;
            read_addr  : in integer range 0 to SIZE - 1;
            read_data  : out std_logic_vector(7 downto 0));
    end component;

    component FontTable is
        port (
            clk, nrst, en : in std_logic;
            char_addr     : in integer range 0 to 255;
            char_x        : in integer range 0 to CHAR_WIDTH - 1;
            char_y        : in integer range 0 to CHAR_HEIGHT - 1;
            pixel         : out std_logic);
    end component;

    constant H_TOTAL : integer := H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;
    constant V_TOTAL : integer := V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;

    signal mono_out : std_logic;
    signal out_en   : std_logic;

    signal horiz_pos  : integer range 0 to H_TOTAL - 1;
    signal verti_pos  : integer range 0 to V_TOTAL - 1;
    signal char_px_x  : integer range 0 to CHAR_WIDTH - 1;
    signal char_px_y  : integer range 0 to CHAR_HEIGHT - 1;
    signal h_read_pos : integer range 0 to TEXT_W - 1;
    signal v_read_pos : integer range 0 to TEXT_H - 1;
    signal read_pos   : integer range 0 to (TEXT_H * TEXT_W) - 1;
    signal cur_char   : std_logic_vector(7 downto 0);

    attribute use_dsp               : string;
    attribute use_dsp of behavioral : architecture is "no";
begin
    text_ram : TextRam
    generic map(
        SIZE => TEXT_W * TEXT_H)
    port map(
        nrst       => nrst,
        write_clk  => data_clk,
        write_en   => s_tvalid,
        write_addr => s_taddr,
        write_data => s_tdata,
        read_clk   => pixel_clk,
        read_addr  => read_pos,
        read_data  => cur_char);

    font_table : FontTable
    port map(
        nrst      => nrst,
        clk       => pixel_clk,
        en        => out_en,
        char_addr => to_integer(unsigned(cur_char)),
        char_x    => char_px_x,
        char_y    => char_px_y,
        pixel     => mono_out);

    read_pos <= v_read_pos * TEXT_W + h_read_pos;

    -- who needs color anyways? :D
    vga_r <= (others => mono_out);
    vga_g <= (others => mono_out);
    vga_b <= (others => mono_out);

    vga_hs <= '1'
        when horiz_pos > H_VISIBLE + H_FRONT_PORCH + 2
        and horiz_pos <= H_TOTAL - H_BACK_PORCH + 2
        and nrst = '1' else '0';
    vga_vs <= '1'
        when verti_pos > V_VISIBLE + V_FRONT_PORCH + 1
        and verti_pos <= V_TOTAL - V_BACK_PORCH + 1
        and nrst = '1' else '0';

    display_proc : process (pixel_clk) begin
        if rising_edge(pixel_clk) then
            if nrst = '0' then
                horiz_pos  <= 0;
                verti_pos  <= 0;
                char_px_x  <= 0;
                char_px_y  <= 0;
                h_read_pos <= 0;
                v_read_pos <= 0;
                out_en     <= '0';
            else
                if clk_en = '1' then
                    -- handle horizontal position
                    if horiz_pos < H_TOTAL - 1 then
                        horiz_pos <= horiz_pos + 1;

                        -- visible area
                        if horiz_pos < H_VISIBLE and verti_pos < V_VISIBLE then

                            -- horizontal character pixel counter
                            if h_read_pos < TEXT_W then -- prevent overflow
                                if char_px_x = CHAR_WIDTH - 1 then
                                    char_px_x  <= 0;
                                    h_read_pos <= h_read_pos + 1;
                                else
                                    char_px_x <= char_px_x + 1;
                                end if;
                            end if;

                            -- enable pixel output
                            out_en <= '1';
                        else
                            out_en <= '0';
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