--! Adder.vhd
--! Alexander Horstkötter 15.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Adder is
    generic (
        WIDTH : positive := 8);
    port (
        a, b : in std_logic_vector(WIDTH - 1 downto 0);
        sum  : out std_logic_vector(WIDTH downto 0));
end entity;

architecture behavioral of Adder is
    component FullAdder is
        port (
            ci, a, b : in std_logic;
            co, sum  : out std_logic);
    end component;

    signal carry : std_logic_vector(WIDTH downto 0);
begin
    carry(0)   <= '0';
    sum(WIDTH) <= carry(WIDTH);

    fas : for i in 0 to WIDTH - 1 generate
        fa : FullAdder
        port map(
            a   => a(i),
            b   => b(i),
            sum => sum(i),
            ci  => carry(i),
            co  => carry(i + 1));
    end generate;

end architecture;