--! FontTable.vhd
--! Alexander Horstkötter 13.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FontTable is
    port (
        clk, nrst : in std_logic;
        read_addr : in integer range 0 to (CHAR_WIDTH_C * CHAR_HEIGHT_C) - 1);
end entity;

architecture behavioral of FontTable is

begin
    process (clk) begin
        if rising_edge(clk) then
            if nrst = '0' then

            else

            end if;
        end if;
    end process;
end architecture;