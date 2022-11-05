--! HexConverter_TB.vhd
--! Alexander Horstkötter 04.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HexConverter_TB is
end entity;

architecture test of HexConverter_TB is
    component HexConverter is
        generic (
            DIGITS : positive);
        port (
            clk, nrst : in std_logic;
            s_tvalid  : in std_logic;
            s_tready  : out std_logic;
            s_tdata   : in std_logic_vector((4 * DIGITS) - 1 downto 0);
            m_tvalid  : out std_logic;
            m_tready  : in std_logic;
            m_tdata   : out std_logic_vector(7 downto 0));
    end component;

    constant message : std_logic_vector(31 downto 0) := x"12345678";

    signal clk, nrst  : std_logic := '0';
    signal in_tvalid  : std_logic := '0';
    signal in_tready  : std_logic;
    signal in_tdata   : std_logic_vector(31 downto 0);
    signal out_tvalid : std_logic;
    signal out_tready : std_logic := '0';
    signal out_tdata  : std_logic_vector(7 downto 0);
    signal out_char   : character;
begin
    DUT : HexConverter
    generic map(
        DIGITS => 8)
    port map(
        clk      => clk,
        nrst     => nrst,
        s_tvalid => in_tvalid,
        s_tready => in_tready,
        s_tdata  => in_tdata,
        m_tvalid => out_tvalid,
        m_tready => out_tready,
        m_tdata  => out_tdata);

    out_char <= character'val(to_integer(unsigned(out_tdata)));

    gen_clk : process begin
        wait for 5 ps;
        clk <= not clk;
    end process;

    gen_stim : process begin
        wait for 20 ps;
        nrst <= '1';
        wait for 20 ps;

        in_tdata  <= message;
        in_tvalid <= '1';
        wait for 10 ps;
        in_tvalid <= '0';

        for i in 0 to 8 loop
            wait for 20 ps;
            out_tready <= '1';
            wait for 20 ps;
            out_tready <= '0';
        end loop;

        wait for 50 ps;
    end process;
end architecture;