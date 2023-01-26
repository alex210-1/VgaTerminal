--! VoronoiRender.vhd
--! Alexander Horstkötter 15.01.2023
--!
--! reference implementation: https://www.shadertoy.com/view/XdSBWV
--!
--! ```GLSL
--! vec2 st = fragCoord.xy / 128.;
--! vec2 i_st = floor(st);
--! vec2 f_st = fract(st);
--!   
--! float m_dist = 100.;
--!   
--! for(int x = -1; x <= 1; ++x) {
--!     for(int y = -1; y <= 1; ++y) {
--!         vec2 neighbor = vec2(float(x),float(y));
--!         vec2 point = rand(i_st + neighbor);
--!         point = 0.5 + 0.5*sin(iTime + 8.0*point);
--!         
--!         vec2 distv = neighbor + point - f_st;
--!         float dist = dot(distv, distv);
--!         
--!         if( dist < m_dist ) {
--!             m_dist = dist;
--!         }
--!     }
--! }
--! fragColor.rgb = color(sqrt(m_dist) * 20. + iTime * 2.);
--! ```

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VoronoiRender is
    port (
        clk, nrst : in std_logic;
        pixel_x   : in unsigned(9 downto 0);
        pixel_y   : in unsigned(9 downto 0);
        beam      : in std_logic;

        R, G, B : out unsigned(3 downto 0));
end entity;

architecture behavioral of VoronoiRender is
    subtype FractPos is unsigned(9 downto 0);

    signal int_pos_x, int_pos_y   : unsigned(2 downto 0); -- cell position (8x8 grid)
    signal frac_pos_x, frac_pos_y : unsigned(6 downto 0); -- fractional position
begin
    -- fix point divide pixel_pos by 128
    int_pos_x  <= pixel_x(9 downto 7);
    int_pos_y  <= pixel_y(9 downto 7);
    frac_pos_x <= pixel_x(6 downto 0);
    frac_pos_y <= pixel_y(6 downto 0);

    process (clk) begin
        if rising_edge(clk) then
            if nrst = '0' then

            else

            end if;
        end if;
    end process;
end architecture;