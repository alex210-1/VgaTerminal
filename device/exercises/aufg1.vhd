--! aufg1.vhd
--! Alexander Horstkötter 19.01.2023

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity aufg1 is
    port (
        SW0, SW1, SW2, SW3                     : in std_logic;
        BTNU, BTNR, BTND, BTNL                 : in std_logic;
        LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7 : out std_logic);
end entity;

architecture behavioral of aufg1 is
begin
    LD0 <= SW0;
    LD1 <= SW1;
    LD2 <= SW2;
    LD3 <= SW3;
    LD4 <= BTNU;
    LD5 <= BTNR;
    LD6 <= BTND;
    LD7 <= BTNL;
end architecture;