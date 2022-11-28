--! SevenSeg.vhd
--! Alexander Horstkötter 08.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SevenSeg is
    port (
        CLK100MHZ                      : in std_logic;
        CPU_RESETN                     : in std_logic;
        CA, CB, CC, CD, CE, CF, CG, DP : out std_logic; -- low active

        AN   : out std_logic_vector(7 downto 0); -- low active
        data : in std_logic_vector(31 downto 0));
end entity;

architecture behavioral of SevenSeg is
    component ClockDivN is
        generic (
            N : positive);
        port (
            rst    : in std_logic;
            clk    : in std_logic;
            output : out std_logic);
    end component;

    signal C       : std_logic_vector(6 downto 0); -- "ABCDEFG"
    signal seg_in  : std_logic_vector(3 downto 0);
    signal n_seg   : unsigned(2 downto 0);
    signal clk_div : unsigned(15 downto 0);
begin

    process (CLK100MHZ) begin
        if rising_edge(CLK100MHZ) then
            if CPU_RESETN = '0' then
                n_seg <= "000";
            else
                if clk_div = 0 then
                    n_seg <= n_seg + 1;
                end if;

                clk_div <= clk_div + 1;
            end if;
        end if;
    end process;

    CA <= not C(6);
    CB <= not C(5);
    CC <= not C(4);
    CD <= not C(3);
    CE <= not C(2);
    CF <= not C(1);
    CG <= not C(0);

    with n_seg select seg_in <=
        data(3 downto 0) when "000",
        data(7 downto 4) when "001",
        data(11 downto 8) when "010",
        data(15 downto 12) when "011",
        data(19 downto 16) when "100",
        data(23 downto 20) when "101",
        data(27 downto 24) when "110",
        data(31 downto 28) when "111",
        "XXXX" when others;

    with n_seg select AN <=
        not "00000001" when "000",
        not "00000010" when "001",
        not "00000100" when "010",
        not "00001000" when "011",
        not "00010000" when "100",
        not "00100000" when "101",
        not "01000000" when "110",
        not "10000000" when "111",
        "XXXXXXXX" when others;

    with seg_in select C <=
        "1111110" when x"0",
        "0110000" when x"1",
        "1101101" when x"2",
        "1111001" when x"3",
        "0110011" when x"4",
        "1011011" when x"5",
        "1011111" when x"6",
        "1110000" when x"7",
        "1111111" when x"8",
        "1111011" when x"9",
        "1110111" when x"A",
        "0011111" when x"B",
        "1001110" when x"C",
        "0111101" when x"D",
        "1001111" when x"E",
        "1000111" when x"F",
        "XXXXXXX" when others;

end architecture;