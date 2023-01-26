--! aufg1_TB.vhd
--! Alexander Horstkötter 19.01.2023

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity aufg1_TB is
end entity;

architecture behavioral of aufg1_TB is
    component aufg1 is
        port (
            SW0, SW1, SW2, SW3                     : in std_logic;
            BTNU, BTNR, BTND, BTNL                 : in std_logic;
            LD0, LD1, LD2, LD3, LD4, LD5, LD6, LD7 : out std_logic);
    end component;

    signal SW, LED : std_logic_vector(7 downto 0);
begin
    DUT : aufg1
    port map(
        SW0  => SW(0),
        SW1  => SW(1),
        SW2  => SW(2),
        SW3  => SW(3),
        BTNU => SW(4),
        BTNR => SW(5),
        BTND => SW(6),
        BTNL => SW(7),
        LD0  => LED(0),
        LD1  => LED(1),
        LD2  => LED(2),
        LD3  => LED(3),
        LD4  => LED(4),
        LD5  => LED(5),
        LD6  => LED(6),
        LD7  => LED(7));

    gen_stim : process begin
        SW <= "00000000";

        for i in 0 to 7 loop
            wait for 1 ns;

            SW <= SW(6 downto 0) & '1';
        end loop;

        wait;
    end process;
end architecture;