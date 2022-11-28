--! LatchTest.vhd
--! Alexander Horstkötter 22.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LatchTest is
    port (
        CLK100MHZ                      : in std_logic;
        CPU_RESETN                     : in std_logic;
        BTNC                           : in std_logic;
        CA, CB, CC, CD, CE, CF, CG, DP : out std_logic; -- low active

        AN : out std_logic_vector(7 downto 0); -- low active
        SW : in std_logic_vector(15 downto 0));
end entity;

architecture behavioral of LatchTest is
    component SevenSeg is
        port (
            CLK100MHZ                      : in std_logic;
            CPU_RESETN                     : in std_logic;
            CA, CB, CC, CD, CE, CF, CG, DP : out std_logic; -- low active

            AN   : out std_logic_vector(7 downto 0); -- low active
            data : in std_logic_vector(31 downto 0));
    end component;

    component Adder is
        generic (
            WIDTH : positive := 8);
        port (
            a, b : in std_logic_vector(WIDTH - 1 downto 0);
            sum  : out std_logic_vector(WIDTH downto 0));
    end component;

    signal latch : std_logic_vector(15 downto 0);
    signal sum   : std_logic_vector(31 downto 0);
begin
    seg : SevenSeg
    port map(
        CLK100MHZ  => CLK100MHZ,
        CPU_RESETN => CPU_RESETN,
        CA         => CA,
        CB         => CB,
        CC         => CC,
        CD         => CD,
        CE         => CE,
        CF         => CF,
        CG         => CG,
        DP         => DP,
        AN         => AN,
        data       => sum);

    add : Adder
    generic map(
        WIDTH => 16)
    port map(
        a   => SW,
        b   => latch,
        sum => sum(16 downto 0));

    sum(31 downto 17) <= (others => '0');

    process (BTNC, SW) begin
        if BTNC = '1' then
            latch <= SW;
        end if;
    end process;
end architecture;