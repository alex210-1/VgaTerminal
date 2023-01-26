--! GrayCode.vhd
--! Alexander Horstkötter 19.01.2023

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity GrayCode is
    port (
        bin  : in std_logic_vector(3 downto 0);
        gray : out std_logic_vector(3 downto 0));
end entity;

architecture behavioral of GrayCode is
begin
    gray(0) <= bin(0) xor bin(1);
    gray(1) <= bin(1) xor bin(2);
    gray(2) <= bin(2) xor bin(3);
    gray(3) <= bin(3);
end architecture;