--! Alexander Horstkötter 02.11.2022
--! https://www.avrfreaks.net/sites/default/files/PS2%20Keyboard.pdf
--! receives raw scancodes as bytes from keyboard and emits 
--! extended 16-bit keycodes + break flag
--! successfully simulated 03.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ScancodeDecoder is
    port (
        clk, nrst     : in std_logic;
        s_tvalid      : in std_logic;
        s_tdata       : in std_logic_vector(7 downto 0);
        m_tvalid      : out std_logic;
        m_tdata_code  : out std_logic_vector(15 downto 0);
        m_tdata_break : out std_logic);
end entity;

architecture behavioral of ScancodeDecoder is
    type DecodeState is (
        IDLE,           -- ready to receive new scancode
        EXTENDED,       -- already has first half of extended keycode
        BREAK,          -- already as break flag
        EXTENDED_BREAK, -- both extended and break
        TRANSMIT);      -- scancode complete. waiting for downstream handshake
    signal decode_state : DecodeState;
begin
    m_tvalid <= '1' when decode_state = TRANSMIT and nrst = '1' else '0';

    process (clk) begin
        if rising_edge(clk) then
            if nrst = '0' then
                decode_state  <= IDLE;
                m_tdata_code  <= (others => '0');
                m_tdata_break <= '0';
            else
                -- push stream handshake
                if s_tvalid then
                    case decode_state is
                        when IDLE =>
                            case s_tdata is
                                when x"E0" =>
                                    decode_state <= EXTENDED;
                                    m_tdata_code <= x"00E0";
                                when x"F0" =>
                                    decode_state  <= BREAK;
                                    m_tdata_break <= '1';
                                when others =>
                                    decode_state <= TRANSMIT;
                                    m_tdata_code <= x"00" & s_tdata;
                            end case;
                        when EXTENDED =>
                            case s_tdata is
                                when x"F0" =>
                                    decode_state  <= EXTENDED_BREAK;
                                    m_tdata_break <= '1';
                                when others =>
                                    decode_state <= TRANSMIT;
                                    m_tdata_code <= x"E0" & s_tdata;
                            end case;
                        when BREAK =>
                            decode_state <= TRANSMIT;
                            m_tdata_code <= x"00" & s_tdata;
                        when EXTENDED_BREAK =>
                            decode_state <= TRANSMIT;
                            m_tdata_code <= x"E0" & s_tdata;
                        when TRANSMIT =>
                    end case;
                end if;

                -- master stream handshake
                if decode_state = TRANSMIT then
                    decode_state  <= IDLE;
                    m_tdata_break <= '0';
                end if;
            end if;
        end if;
    end process;
end architecture;