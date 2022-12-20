--! MclkGen.vhd
--! Alexander Horstkötter 02.12.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MclkGen is
    port (
        CPU_RESETN          : in std_logic;
        CLK100MHZ, LRCLK_IN : in std_logic;
        MCLK_OUT            : out std_logic);
end entity;

architecture behavioral of MclkGen is
    component I2S_clkgen is
        port (
            clk_440mhz, locked : out std_logic;
            clk_in, resetn     : in std_logic);
    end component;

    component MclkGenPll is
        port (
            nrst                  : in std_logic;
            clk_440mhz, lrclk_ref : in std_logic;
            m_clk                 : out std_logic);
    end component;

    signal locked, clk_440mhz : std_logic;
begin
    clk_gen : I2S_clkgen
    port map(
        resetn     => CPU_RESETN,
        clk_in     => CLK100MHZ,
        clk_440mhz => clk_440mhz,
        locked     => locked);

    pll : MclkGenPll
    port map(
        nrst       => CPU_RESETN, -- TODO locked
        clk_440mhz => clk_440mhz,
        lrclk_ref  => LRCLK_IN,
        m_clk      => MCLK_OUT);

end architecture;