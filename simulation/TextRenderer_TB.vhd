--! TextRenderer_TB.vhd
--! Alexander Horstkötter 08.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TextRenderer_TB is
end entity;

architecture test of TextRenderer_TB is
    component TextRenderer480p is
        generic (
            TEXT_W : integer := 40;
            TEXT_H : integer := 20);
        port (
            clk100mhz, nrst     : in std_logic;
            s_tvalid            : in std_logic;
            s_taddr             : in integer range 0 to (TEXT_W * TEXT_H) - 1;
            s_tdata             : in std_logic_vector(7 downto 0);
            vga_r, vga_g, vga_b : out std_logic_vector(3 downto 0);
            vga_vs, vga_hs      : out std_logic); --! low active
    end component;

    signal clk, nrst           : std_logic := '0';
    signal vga_r, vga_g, vga_b : std_logic_vector(3 downto 0);
    signal vga_vs, vga_hs      : std_logic;
    signal ascii               : std_logic_vector(7 downto 0);
    signal ascii_addr          : integer range 0 to 799 := 0;
    signal ascii_valid         : std_logic;
begin
    DUT : TextRenderer480p
    port map(
        clk100mhz => clk,
        nrst      => nrst,
        s_tvalid  => ascii_valid,
        s_taddr   => ascii_addr,
        s_tdata   => ascii,
        vga_r     => vga_r,
        vga_g     => vga_g,
        vga_b     => vga_b,
        vga_hs    => vga_hs,
        vga_vs    => vga_vs);

    gen_clk : process begin
        wait for 5 ns;
        clk <= not clk;
    end process;

    gen_stim : process begin
        wait for 20 ns;
        nrst <= '1';
        wait for 20 ns;

        for i in 48 to 87 loop
            ascii <= std_logic_vector(to_unsigned(i, 8));

            ascii_valid <= '1';
            wait for 10 ns;
            ascii_valid <= '0';
            wait for 10 ns;

            ascii_addr <= ascii_addr + 1;
        end loop;

        wait;
    end process;
end architecture;