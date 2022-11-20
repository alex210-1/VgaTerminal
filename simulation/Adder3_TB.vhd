--! Adder3_TB.vhd
--! Alexander Horstkötter 15.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Adder3_TB is
end entity;

architecture behavioral of Adder3_TB is
    component Adder3 is
        port (
            SW  : in std_logic_vector(5 downto 0);
            LED : out std_logic_vector(3 downto 0));
    end component;

    signal SWx  : std_logic_vector(5 downto 0);
    signal LEDx : std_logic_vector(3 downto 0);
begin
    add : Adder3
    port map(
        SW  => SWx,
        LED => LEDx);

    gen_stim : process begin
        wait for 10 ps;

        SWx <= "000000";
        wait for 10 ps;

        SWx <= "010001";
        wait for 10 ps;

        SWx <= "111111";
        wait;
    end process;
end architecture;