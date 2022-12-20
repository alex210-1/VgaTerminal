--! ShiftTest.vhd
--! Alexander Horstkötter 29.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ShiftTest is
    port (
        BTNC, BTNU, BTNL : in std_logic;
        LED              : out std_logic_vector(15 downto 0);
        SW               : in std_logic_vector(15 downto 0));
end entity;

architecture behavioral of ShiftTest is
    signal clk, rst, ld : std_logic;
    signal shift        : std_logic_vector(7 downto 0);
begin
    rst <= BTNL;
    clk <= BTNC;
    ld  <= BTNU;
    LED <= (7 downto 0 => shift, others => '0');

    process (clk, rst) begin
        if rst = '1' then
            shift <= (others => '0');
        elsif rising_edge(clk) then
            if ld = '1' then
                shift(3 downto 0) <= SW(3 downto 0);
            else
                shift <= shift(6 downto 0) & shift(7);
            end if;
        end if;
    end process;
end architecture;