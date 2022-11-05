--! ScancodeDecoder_TB.vhd
--! Alexander Horstkötter 03.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ScancodeDecoder_TB is
end entity;

architecture behavioral of ScancodeDecoder_TB is
    component ScancodeDecoder is
        port (
            clk, nrst     : in std_logic;
            s_tvalid      : in std_logic;
            s_tdata       : in std_logic_vector(7 downto 0);
            m_tvalid      : out std_logic;
            m_tdata_code  : out std_logic_vector(15 downto 0);
            m_tdata_break : out std_logic);
    end component;

    type ScanCodes is array(0 to 7) of std_logic_vector(7 downto 0);
    constant scan_codes : ScanCodes := (
        x"1C",              -- make A
        x"F0", x"1C",       -- break A
        x"E0", x"70",       -- make INSERT
        x"E0", x"F0", x"70" -- break INSERT
    );

    signal clk, nrst       : std_logic := '0';
    signal in_tvalid       : std_logic;
    signal in_tdata        : std_logic_vector(7 downto 0);
    signal out_tvalid      : std_logic;
    signal out_tdata_break : std_logic;
    signal out_tdata_code  : std_logic_vector(15 downto 0);
begin
    DUT : ScancodeDecoder
    port map(
        clk           => clk,
        nrst          => nrst,
        s_tvalid      => in_tvalid,
        s_tdata       => in_tdata,
        m_tvalid      => out_tvalid,
        m_tdata_break => out_tdata_break,
        m_tdata_code  => out_tdata_code);

    gen_clk : process begin
        wait for 5 ps;
        clk <= not clk;
    end process;

    gen_stim : process begin
        wait for 20 ps;
        nrst <= '1';

        for i in scan_codes'range loop

            in_tvalid <= '1';
            in_tdata  <= scan_codes(i);

            wait for 20 ps;
            in_tvalid <= '0';
            wait for 20 ps;
        end loop;
    end process;
end architecture;