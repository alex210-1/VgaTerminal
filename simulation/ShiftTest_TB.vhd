--! ShiftTest_TB.vhd
--! Alexander Horstkötter 29.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ShiftTest_TB is
end entity;

architecture behavioral of ShiftTest_TB is
    component ShiftTest is
        port (
            BTNC, BTNU, BTNL : in std_logic; -- rst, clk, ld
            LED              : out std_logic_vector(15 downto 0);
            SW               : in std_logic_vector(15 downto 0));
    end component;

    signal SW, LED      : std_logic_vector(15 downto 0);
    signal clk, rst, ld : std_logic;
begin
    DUT : ShiftTest
    port map(
        BTNC => clk,
        BTNU => ld,
        BTNL => rst,
        LED  => LED,
        SW   => SW);

    gen_stim : process begin
        SW  <= (3 downto 0 => "0101", others => '0');
        rst <= '1';
        ld  <= '0';
        clk <= '0';
        wait for 1 ns;

        rst <= '0';
        wait for 1 ns;

        ld <= '1';
        wait for 1 ns;

        clk <= '1';
        wait for 1 ns;

        clk <= '0';
        ld  <= '0';
        wait for 1 ns;

        for i in 1 to 4 loop
            clk <= '1';
            wait for 1 ns;

            clk <= '0';
            wait for 1 ns;
        end loop;

        ld <= '1';
        wait for 1 ns;

        clk <= '1';
        wait for 1 ns;

        clk <= '0';
        ld  <= '0';
        wait for 1 ns;

        rst <= '0';
        wait for 1 ns;

        rst <= '1';
        wait;
    end process;
end architecture;