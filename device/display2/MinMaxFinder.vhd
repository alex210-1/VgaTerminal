--! MinMaxFinder.vhd
--! Alexander Horstkötter 17.01.2023
--!
--! Determines the largest/smalles of a list of input vectors
--! The Algorithm works like this:
--!
--! let target := 1 when looking for largest, 0 for smallest
--! let M := row matrix of input vectors of size M[N_inputs][N_bits]
--! let out := vector of size N_inputs
--!
--! for each bit b:
--!   eq := M[0 .. N_inputs][bit] are all equal
--!
--!   for each input i:
--!     match := (M[i][b] == target)
--!     out[i] := out[i] & (match | eq)
--! 
--! output now contains a 1 for every smallest/largest input.
--! the input matrix is masked with this vector.
--! because there can only be multiple values if they are equal this is not a problem.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MinMaxFinder is
    port (
        clk, nrst : in std_logic);
end entity;

architecture behavioral of MinMaxFinder is

begin
    process (clk) begin
        if rising_edge(clk) then
            if nrst = '0' then

            else

            end if;
        end if;
    end process;
end architecture;