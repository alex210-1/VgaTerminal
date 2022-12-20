--! FreqDiv_TB.vhd
--! Alexander Horstkötter 06.12.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FreqDiv_TB is
end entity;

architecture behavioral of FreqDiv_TB is
    component FreqDiv is
        generic (
            FREQ_IN, FREQ_OUT : real);
        port (
            clk_in, rst : in std_logic;
            clk_out     : out std_logic);
    end component;

    signal rst     : std_logic := '1';
    signal clk_in  : std_logic := '1';
    signal clk_out : std_logic;
begin
    -- DIV by 10 for testing
    DUT : FreqDiv
    generic map(
        FREQ_IN  => 100000000.0,
        FREQ_OUT => 200.0)
    port map(
        clk_in  => clk_in,
        clk_out => clk_out,
        rst     => rst);

    gen_clk : process begin
        -- 100 MHz
        wait for 5 ns;
        clk_in <= not clk_in;
    end process;

    gen_stim : process begin
        wait for 1 ns;
        rst <= '0';
    end process;
end architecture;

configuration cfg of FreqDiv_TB is
    for behavioral
        for DUT : FreqDiv
            use entity work.FreqDiv(exercise);
        end for;
    end for;
end configuration cfg;