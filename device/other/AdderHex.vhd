--! AdderHex.vhd
--! Alexander Horstkötter 15.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AdderHex is
    port (
        CLK100MHZ                      : in std_logic;
        CPU_RESETN                     : in std_logic;
        CA, CB, CC, CD, CE, CF, CG, DP : out std_logic; -- low active

        AN : out std_logic_vector(7 downto 0); -- low active
        SW : in std_logic_vector(15 downto 0));
end entity;

architecture behavioral of AdderHex is
    component Adder is
        generic (
            WIDTH : positive := 8);
        port (
            a, b : in std_logic_vector(WIDTH - 1 downto 0);
            sum  : out std_logic_vector(WIDTH downto 0));
    end component;

    component SevenSeg is
        port (
            CLK100MHZ                      : in std_logic;
            CPU_RESETN                     : in std_logic;
            CA, CB, CC, CD, CE, CF, CG, DP : out std_logic; -- low active

            AN : out std_logic_vector(7 downto 0); -- low active
            SW : in std_logic_vector(15 downto 0));
    end component;

    signal sum : std_logic_vector(8 downto 0);
begin
    add : Adder
    generic map(
        WIDTH => 8)
    port map(
        a   => SW(7 downto 0),
        b   => SW (15 downto 8),
        sum => sum);

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
        SW         => "0000000" & sum);

end architecture;