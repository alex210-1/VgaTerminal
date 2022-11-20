library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package constants is
    constant CHAR_WIDTH  : integer := 16;
    constant CHAR_HEIGHT : integer := 24;
    constant CHAR_SIZE   : integer := CHAR_WIDTH * CHAR_HEIGHT;
end package;