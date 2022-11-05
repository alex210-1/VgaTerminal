--! HexConverter.vhd
--! takes a std_logic_vector stream and outputs an ascii stream with the hex representation
--! useful for debugging datastreams
--! Alexander Horstkötter 04.11.2022
--! successfully simulated 04.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity HexConverter is
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
end entity;

architecture behavioral of HexConverter is
    signal in_buffer : std_logic_vector((4 * DIGITS) - 1 downto 0);
    signal state     : integer range 0 to DIGITS;
begin
    s_tready <= '1' when state = 0 and nrst = '1' else '0';

    process (clk)
        procedure emit_digit(
            signal nibble : in std_logic_vector(3 downto 0)) is
            variable char : character;
        begin
            with nibble select char :=
                '0' when 0x"0",
                '1' when 0x"1",
                '2' when 0x"2",
                '3' when 0x"3",
                '4' when 0x"4",
                '5' when 0x"5",
                '6' when 0x"6",
                '7' when 0x"7",
                '8' when 0x"8",
                '9' when 0x"9",
                'A' when 0x"A",
                'B' when 0x"B",
                'C' when 0x"C",
                'D' when 0x"D",
                'E' when 0x"E",
                'F' when 0x"F",
                'X' when others;

            m_tdata  <= std_logic_vector(to_unsigned(character'pos(char), 8));
            m_tvalid <= '1';
        end procedure;
    begin
        if rising_edge(clk) then
            if nrst = '0' then
                state    <= 0;
                m_tvalid <= '0';
            else
                if m_tvalid = '1' and m_tready = '1' then
                    m_tvalid <= '0';
                end if;

                case state is
                    when 0 =>
                        if s_tvalid = '1' then
                            in_buffer <= s_tdata((4 * DIGITS) - 5 downto 0) & "0000";
                            emit_digit(s_tdata((4 * DIGITS) - 1 downto (4 * DIGITS) - 4));
                            state <= 1;
                        end if;
                    when 1 to DIGITS - 1 =>
                        if m_tready = '1' then
                            emit_digit(in_buffer((4 * DIGITS) - 1 downto (4 * DIGITS) - 4));
                            in_buffer <= in_buffer((4 * DIGITS) - 5 downto 0) & "0000";
                            state     <= state + 1;
                        end if;
                    when DIGITS =>
                        if m_tready = '1' then
                            state <= 0;
                        end if;
                end case;
            end if;
        end if;
    end process;
end architecture;