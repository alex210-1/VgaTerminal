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

        AN : out std_logic_vector(7 downto 0); -- low active
        SW : in std_logic_vector(15 downto 0));
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
    signal n_seg   : unsigned(1 downto 0);
    signal seg_in  : std_logic_vector(3 downto 0);
    signal seg_clk : std_logic;
begin
    clk_div : ClockDivN
    generic map(
        N => 2 ** 16)
    port map(
        clk    => CLK100MHZ,
        rst    => not CPU_RESETN,
        output => seg_clk);

    process (CLK100MHZ) begin
        if rising_edge(CLK100MHZ) then
            if CPU_RESETN = '0' then
                n_seg <= "00";
            else
                if seg_clk = '1' then
                    n_seg <= n_seg + 1;
                end if;
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
        SW(3 downto 0) when "00",
        SW(7 downto 4) when "01",
        SW(11 downto 8) when "10",
        SW(15 downto 12) when "11",
        "XXXX" when others;

    with n_seg select AN <=
        not "00000001" when "00",
        not "00000010" when "01",
        not "00000100" when "10",
        not "00001000" when "11",
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