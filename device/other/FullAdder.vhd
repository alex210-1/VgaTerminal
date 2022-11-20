--! FullAdder.vhd
--! Alexander Horstkötter 15.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FullAdder is
    port (
        ci, a, b : in std_logic;
        co, sum  : out std_logic);
end entity;

architecture behavioral of FullAdder is begin
    sum <= ci xor a xor b;
    co  <= (ci and a) or (a and b) or (b and ci);
end architecture;