--! Alexander Horstkötter 01.11.2022
--! successfully simulated 01.11.2022
--!
--! UART transmit process:
--! {signal: [
--!   {name: 'baud_clk', wave: 'n|...........'},
--!   {name: 'data',     wave: '1|022.....21x', data: ['LSB', '...', 'MSB']},
--!   {name: 'state',    wave: '2|22.......2.', data: ['0', '1', '2 to 9', '0']}
--! ]}

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UartTransmitter is
    generic (
        BAUD     : real := 9600.0;
        CLK_FREQ : real := 100000000.0);
    port (
        clk, nrst : in std_logic;
        -- UART
        rts     : in std_logic; --! request to send. other device is ready to receive. low active!
        rxd_out : out std_logic;
        -- AXI4-stream slave
        s_tvalid : in std_logic;  --! data available from master
        s_tready : out std_logic; --! data ready to be received
        s_tdata  : in std_logic_vector(7 downto 0));
end entity;

architecture Behavioral of UartTransmitter is
    component ClockDivN
        generic (
            N : positive);
        port (
            rst    : in std_logic;
            clk    : in std_logic;
            output : out std_logic);
    end component;

    signal transmit_buffer : std_logic_vector(7 downto 0);
    signal baud_clk        : std_logic; --! clock with frequency BAUD
    signal transmit_state  : unsigned(3 downto 0);
begin
    clk_div : ClockDivN
    generic map(
        N => integer(CLK_FREQ / BAUD))
    port map(
        rst    => not nrst,
        clk    => clk,
        output => baud_clk);

    transmit_sm : process (clk) begin
        if rising_edge(clk) then
            if nrst = '0' then
                s_tready       <= '0';
                rxd_out        <= '1';
                transmit_state <= "0000";
            else
                -- finish axi-stream handshake
                if s_tready = '1' then
                    transmit_buffer <= s_tdata;
                    s_tready        <= '0';
                end if;

                -- transmission state machine, synchronous to baud rate
                if baud_clk = '1' then
                    case to_integer(transmit_state) is
                        when 0 =>
                            -- ready to receive, send stop bit
                            if rts = '0' and s_tvalid = '1' then
                                transmit_state <= transmit_state + 1;
                                rxd_out        <= '0';
                                s_tready       <= '1';
                                s_tready       <= '1';
                            end if;
                        when 1 to 8 =>
                            -- shift out transmit buffer
                            rxd_out         <= transmit_buffer(0);
                            transmit_state  <= transmit_state + 1;
                            transmit_buffer <= '0' & transmit_buffer(7 downto 1);
                        when others =>
                            -- send stop bit and start again
                            rxd_out        <= '1';
                            transmit_state <= "0000";
                    end case;
                end if;
            end if;
        end if;
    end process;

end Behavioral;