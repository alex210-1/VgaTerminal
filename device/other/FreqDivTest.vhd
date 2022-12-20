--! FreqDivTest.vhd
--! Alexander Horstkötter 06.12.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FreqDivTest is
    port (
        CLK100MHZ, CPU_RESETN : in std_logic;
        LED                   : out std_logic_vector(0 downto 0));
end entity;

architecture behavioral of FreqDivTest is
    component FreqDiv is
        generic (
            FREQ_IN, FREQ_OUT : real);
        port (
            clk_in, rst : in std_logic;
            clk_out     : out std_logic);
    end component;
begin
    DUT : FreqDiv
    generic map(
        FREQ_IN  => 100000000.0,
        FREQ_OUT => 2.0)
    port map(
        clk_in  => CLK100MHZ,
        clk_out => LED(0),
        rst     => not CPU_RESETN);
end architecture;