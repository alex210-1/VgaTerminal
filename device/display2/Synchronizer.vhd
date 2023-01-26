--! Synchronizer.vhd
--! Alexander Horstkötter 10.01.2023

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Synchronizer is
    port (
        clk, nrst : in std_logic;
        hcount    : in unsigned(9 downto 0);
        vcount    : in unsigned(9 downto 0);

        hsync : out std_logic;
        vsync : out std_logic;

        pixel_x : out unsigned(9 downto 0);
        pixel_y : out unsigned(9 downto 0);
        beam    : out std_logic);
end entity;

architecture behavioral of Synchronizer is
    constant H_SYNC   : integer := 96;
    constant H_BPORCH : integer := 48;
    constant H_WIDTH  : integer := 640;
    constant V_SYNC   : integer := 2;
    constant V_BPORCH : integer := 29;
    constant V_WIDTH  : integer := 480;

    constant H_START : integer := H_SYNC + H_BPORCH;
    constant V_START : integer := V_SYNC + V_BPORCH;
    constant H_END   : integer := H_START + H_WIDTH;
    constant V_END   : integer := V_START + V_WIDTH;
begin
    process (clk)
        variable h_draw, v_draw : std_logic;
    begin
        if rising_edge(clk) then
            if nrst = '0' then
                hsync   <= '1';
                vsync   <= '1';
                beam    <= '0';
                pixel_x <= (others => '0');
                pixel_y <= (others => '0');
            else
                h_draw := '1' when hcount >= H_START and hcount < H_END else '0';
                v_draw := '1' when vcount >= V_START and vcount < V_END else '0';

                hsync <= '0' when hcount < H_SYNC else '1';
                vsync <= '0' when vcount < V_SYNC else '1';

                beam <= '1' when h_draw = '1' and v_draw = '1' else '0';

                -- check not really neccessary, just neater
                if h_draw = '1' then
                    pixel_x <= hcount - H_START;
                else
                    pixel_x <= (others => '0');
                end if;

                if v_draw = '1' then
                    pixel_y <= vcount - V_START;
                else
                    pixel_y <= (others => '0');
                end if;
            end if;
        end if;
    end process;

end architecture;