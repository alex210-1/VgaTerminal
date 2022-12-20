--! MclkGen_TB.vhd
--! Alexander Horstkötter 02.12.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MclkGen_TB is
end entity;

architecture behavioral of MclkGen_TB is
    component MclkGenPll is
        port (
            nrst                  : in std_logic;
            clk_440mhz, lrclk_ref : in std_logic;
            m_clk                 : out std_logic);
    end component;

    signal nrst       : std_logic := '0';
    signal clk_440mhz : std_logic := '0';
    signal lr_clk     : std_logic := '0';
    signal m_clk      : std_logic;
begin
    DUT : MclkGenPll
    port map(
        nrst       => nrst,
        clk_440mhz => clk_440mhz,
        lrclk_ref  => lr_clk,
        m_clk      => m_clk);

    gen_clk_440 : process begin
        wait for 1.136 ns;
        clk_440mhz <= not clk_440mhz;
    end process;

    gen_lr_clk : process begin
        -- 43.5 kHz
        wait for 11.494 us;
        lr_clk <= not lr_clk;
    end process;

    gen_stim : process begin
        wait for 10 ns;
        nrst <= '1';
    end process;
end architecture;