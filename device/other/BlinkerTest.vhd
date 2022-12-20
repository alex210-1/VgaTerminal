--! BlinkerTest.vhd
--! Alexander Horstkötter 19.12.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BlinkerTest is
    port (
        CLK100MHZ  : in std_logic;
        CPU_RESETN : in std_logic;
        SW         : in std_logic_vector(2 downto 0);
        LED        : out std_logic_vector(5 downto 0));
end entity;

architecture structural of BlinkerTest is
    component BlinkerStateMachine is
        port (
            clk, nrst : in std_logic;
            L, R, W   : in std_logic;
            light     : out std_logic_vector(5 downto 0));
    end component;

    component FreqDiv is
        generic (
            FREQ_IN, FREQ_OUT : real);
        port (
            clk_in, rst : in std_logic;
            clk_out     : out std_logic);
    end component;

    signal clk : std_logic;
begin
    clk_div : FreqDiv
    generic map(
        FREQ_IN  => 100000000.0,
        FREQ_OUT => 2.0)
    port map(
        rst     => not CPU_RESETN,
        clk_in  => CLK100MHZ,
        clk_out => clk);

    DUT : BlinkerStateMachine
    port map(
        clk   => clk,
        nrst  => CPU_RESETN,
        W     => SW(2),
        L     => SW(1),
        R     => SW(0),
        light => LED);
end architecture;