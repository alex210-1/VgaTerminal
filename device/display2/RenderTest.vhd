--! Render.vhd
--! Alexander Horstkötter 10.01.2023

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RenderTest is
    port (
        clk, nrst : in std_logic;
        pixel_x   : in unsigned(9 downto 0);
        pixel_y   : in unsigned(9 downto 0);
        beam      : in std_logic;

        R, G, B : out unsigned(3 downto 0));
end entity;

architecture behavioral of RenderTest is

begin
    process (clk) begin
        if rising_edge(clk) then
            R <= "0000";
            G <= "0000";
            B <= "0000";

            if nrst = '0' then
                -- none
            else
                if beam = '1' then
                    R <= pixel_x(3 downto 0);
                    G <= pixel_y(3 downto 0);
                end if;
            end if;
        end if;
    end process;
end architecture;