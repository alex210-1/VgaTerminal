--! FontTable_TB.vhd
--! Alexander Horstkötter 13.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fonttable.all;
use std.env.finish;

entity FontTable_TB is
end entity;

architecture behavioral of FontTable_TB is
    signal ascii : std_logic_vector(7 downto 0) := x"35";
begin
    process
        variable line  : string(1 to 16);
        variable pixel : std_logic;

        variable char_pos  : integer := to_integer(unsigned(ascii)) - 32;
        variable pixel_pos : integer;
    begin
        for y_i in 0 to 23 loop
            for x_i in 0 to 15 loop

                pixel_pos     := y_i * CHAR_WIDTH + x_i;
                pixel         := FONT_TABLE(2)(pixel_pos);
                line(x_i + 1) := 'X' when pixel = '1' else ' ';
            end loop;

            report line;
        end loop;

        finish;
    end process;
end architecture;