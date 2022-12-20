--! BlinkerStateMachine_TB.vhd
--! Alexander Horstkötter 19.12.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BlinkerStateMachine_TB is
end entity;

architecture behavioral of BlinkerStateMachine_TB is
    component BlinkerStateMachine is
        port (
            clk, nrst : in std_logic;
            L, R, W   : in std_logic;
            light     : out std_logic_vector(5 downto 0));
    end component;

    signal clk, nrst : std_logic := '0';
    signal L, R, W   : std_logic := '0';
    signal light     : std_logic_vector(5 downto 0);
begin
    DUT : BlinkerStateMachine
    port map(
        clk   => clk,
        nrst  => nrst,
        L     => L,
        R     => R,
        W     => W,
        light => light);

    gen_clk : process begin
        wait for 5 ns;
        clk <= not clk;
    end process;

    gen_stim : process begin
        wait for 20 ns;
        nrst <= '1';

        -- blink left
        wait for 20 ns;
        L <= '1';
        wait for 100 ns;
        L <= '0';

        -- blink right
        wait for 20 ns;
        R <= '1';
        wait for 100 ns;
        R <= '0';

        -- warn
        wait for 20 ns;
        W <= '1';
        wait for 100 ns;
        W <= '0';

    end process;
end architecture;