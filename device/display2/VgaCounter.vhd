--! VgaCounter.vhd
--! Alexander Horstkötter 10.01.2023

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VgaCounter is
    port (
        clk, nrst : in std_logic;
        hcount    : out unsigned(9 downto 0);
        vcount    : out unsigned(9 downto 0));
end entity;

architecture behavioral of VgaCounter is
    constant T_HORIZ : integer := 800;
    constant N_LINES : integer := 521;

    signal clk_div : unsigned(1 downto 0); --! divide by 4
begin
    process (clk) begin
        if rising_edge(clk) then
            if nrst = '0' then
                clk_div <= (others => '0');
                hcount  <= (others => '0');
                vcount  <= (others => '0');
            else
                clk_div <= clk_div + 1;

                if clk_div = "11" then
                    hcount <= hcount + 1;

                    if hcount = to_unsigned(T_HORIZ - 1, 10) then
                        hcount <= (others => '0');
                        vcount <= vcount + 1;

                        if vcount = to_unsigned(N_LINES - 1, 10) then
                            vcount <= (others => '0');
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture;