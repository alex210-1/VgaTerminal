-- ClockDivN.vhd
--
-- Simple clock divider, automatically chooses counter size, outputs 1-tick pulse
-- Alexander Horstkötter 19.10.2022

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.MATH_REAL.ALL;

entity ClockDivN is
    generic (
        N: positive);
    port (
        rst: in std_logic;
        clk: in std_logic;
        output: out std_logic);
end ClockDivN;

architecture Behavioral of ClockDivN is
    constant WIDTH: positive := positive(ceil(log2(real(N))));
    
    signal counter: unsigned(WIDTH - 1 downto 0);
begin
    process(clk, rst) begin
        if rising_edge(clk) then
            if rst = '1' then
                counter <= to_unsigned(0, WIDTH);
            else
                counter <= counter + 1;
            end if;
            
            if counter = to_unsigned(N - 1, WIDTH) then
                counter <= to_unsigned(0, WIDTH);
                output <= '1';
            else
                output <= '0';
            end if;
        end if;
    end process;

end Behavioral;
