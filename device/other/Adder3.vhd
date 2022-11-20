--! Adder3.vhd
--! Alexander Horstkötter 15.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Adder3 is
    port (
        SW  : in std_logic_vector(5 downto 0);
        LED : out std_logic_vector(3 downto 0));
end entity;

architecture behavioral of Adder3 is
    component Adder is
        generic (
            WIDTH : positive := 8);
        port (
            a, b : in std_logic_vector(WIDTH - 1 downto 0);
            sum  : out std_logic_vector(WIDTH downto 0));
    end component;
begin
    add : Adder
    generic map(
        WIDTH => 3)
    port map(
        a   => SW(2 downto 0),
        b   => SW(5 downto 3),
        sum => LED);

end architecture;