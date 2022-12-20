--! FreqDiv.vhd
--! Alexander Horstkötter 06.12.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity FreqDiv is
    generic (
        FREQ_IN, FREQ_OUT : real);
    port (
        clk_in, rst : in std_logic;
        clk_out     : out std_logic);
end entity;

architecture int of FreqDiv is
    constant MAX_COUNT : positive := positive(round((FREQ_IN / FREQ_OUT) / 2.0));

    signal count : integer range 0 to MAX_COUNT - 1;
begin
    process (clk_in, rst) begin
        if rst = '1' then
            clk_out <= '0';
            count   <= 0;
        elsif rising_edge(clk_in) then
            if count = MAX_COUNT - 1 then
                count   <= 0;
                clk_out <= not clk_out;
            else
                count <= count + 1;
            end if;
        end if;
    end process;
end architecture;

-- architecture exercise of FreqDiv is
--     signal count : unsigned(25 downto 0);
-- begin
--     process (clk_in, rst) begin
--         if rst = '1' then
--             count <= (others => '0');
--         elsif rising_edge(clk_in) then
--             if count = to_unsigned(500000 - 1, 26) then
--                 count <= (others => '0');
--             else
--                 count <= count + 1;
--             end if;
--         end if;
--     end process;

--     -- warning: hazards!
--     clk_out <= '1' when count > to_unsigned(250000 - 1, 26) else '0';
-- end architecture;