--! Basic PS/2 receiver. outpust raw received data via axi4-stream
--! Alexander Horstkötter 02.11.2022
--! simulated successfully 02.11.2022
--!
--! PS/2 unidirectional receive process: https://de.wikipedia.org/wiki/PS/2-Schnittstelle
--! pulling low of signals not currently implemented
--! {signal: [
--!   {node: 'A..B.C..........D..E'},
--!   {name: 'clk',   wave: '0..1..N.........0.1',  phase: 0.5},
--!   {name: 'data',  wave: '0.1..022.....21....', data: ['LSB', '...', 'MSB']},
--!   {name: 'state', wave: '2.....22......22....', data: ['0', '1', '2 to 8', '9', '0'], phase: 0.5},
--!   ], edge : [
--!   	'A<->B pulled low by host', 'B+C ready to receive', 'C<->D clock and data from device', 'D+E (ack by host)'
--!   ]
--! }

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ps2Receiver is
    port (
        clk, nrst         : in std_logic;
        ps2_clk, ps2_data : in std_logic;
        m_tready          : in std_logic;
        m_tvalid          : out std_logic;
        m_tdata           : out std_logic_vector(7 downto 0));
end entity;

architecture behavioral of Ps2Receiver is
    signal last_clk       : std_logic; -- used for edge detection
    signal receive_buffer : std_logic_vector(7 downto 0);
    signal receive_state  : unsigned(3 downto 0);
begin
    process (clk) begin
        if rising_edge(clk) then
            if nrst = '0' then
                last_clk       <= '0';
                m_tvalid       <= '0';
                receive_buffer <= "00000000";
                receive_state  <= "0000";
            else

                -- detect falling edge
                if last_clk = '1' and ps2_clk = '0' then
                    case to_integer(receive_state) is
                        when 0 =>
                            -- start bit
                            if ps2_data = '0' then
                                receive_state <= receive_state + 1;
                            end if;
                        when 1 to 8 =>
                            -- shift in data
                            receive_buffer <= ps2_data & receive_buffer(7 downto 1);
                            receive_state  <= receive_state + 1;
                        when others =>
                            -- stop bit, output result
                            m_tdata        <= receive_buffer;
                            receive_buffer <= "00000000";
                            receive_state  <= "0000";
                            m_tvalid       <= '1';
                    end case;
                end if;

                -- axi-stream handshake
                if m_tvalid = '1' and m_tready = '1' then
                    m_tvalid <= '0';
                end if;

                last_clk <= ps2_clk;
            end if;
        end if;
    end process;
end architecture;