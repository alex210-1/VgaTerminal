library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all; -- only one import needed

-- takes two unsigned numbers, adds them and returns the sum as a signed number
-- also adds a generic constant integer
entity TestEntity is
    generic (
        OFFSET_GEN : integer := 42);
    port (
        -- a signal with wrong sign cannot be connected to these ports
        input_a : in unsigned(5 downto 0);
        input_b : in unsigned(5 downto 0);
        sum     : out signed(9 downto 0));
end TestEntity;

architecture Behavioral of TestEntity is
    signal sum_unsigned : unsigned(9 downto 0);

    -- conversion of integer type to unsigned. Number of bits needs to be specified
    constant offset : signed(9 downto 0) := to_signed(OFFSET_GEN, 10);
begin
    -- this uses unsigned addition because it acts on unsigned types
    sum_unsigned <= resize(input_a, 10) + resize(input_b, 10);

    -- explicitly casts unsigned to signed. This does not change the bits
    -- this uses signed addition, the compile would't allow adding unsigned.
    sum <= signed(sum_unsigned) + offset;

end Behavioral;