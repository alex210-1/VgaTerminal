--! VgaTest_TB.vhd
--! Alexander Horstkötter 15.01.2023

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VgaTest_TB is
end entity;

architecture behavioral of VgaTest_TB is
    component VgaTest is
        port (
            CLK100MHZ, CPU_RESETN : in std_logic;
            VGA_R, VGA_G, VGA_B   : out unsigned(3 downto 0);
            VGA_HS, VGA_VS        : out std_logic);
    end component;

    signal clk  : std_logic := '1';
    signal nrst : std_logic := '0';

    signal VGA_R, VGA_G, VGA_B : unsigned(3 downto 0);
    signal VGA_HS, VGA_VS      : std_logic;
begin
    DUT : VgaTest
    port map(
        CLK100MHZ  => clk,
        CPU_RESETN => nrst,
        VGA_R      => VGA_R,
        VGA_G      => VGA_G,
        VGA_B      => VGA_B,
        VGA_HS     => VGA_HS,
        VGA_VS     => VGA_VS);

    gen_clk : process begin
        wait for 5 ns;
        clk <= not clk;
    end process;

    gen_stim : process begin
        wait for 20 ns;
        nrst <= '1';
    end process;
end architecture;