--! Uart receiver. Uses a state machine and a clock with 8 times the baud rate for sampling.
--! Alexander Horstkötter 01.11.2022
--! simulated successfully 01.11.2022
--!
--! UART receive process:
--! {signal: [
--!   {name: 'clk/8', wave: 'p....Pp......Pp...|'},
--!   {name: 'input', wave: '10.......2.......2|', data: ['LSB', '...']},
--!   {name: 'state', wave: '22...2.......2....|', data: ['0', '1-4', '5-12', '13-20']}
--! ]}

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UartReceiver is
    generic (
        BAUD     : real := 9600.0;
        CLK_FREQ : real := 100000000.0);
    port (
        clk, nrst : in std_logic;
        -- UART
        txd_in : in std_logic;
        cts    : out std_logic; --! clear to send. this device is ready to receive
        -- AXI4-stream master
        m_tvalid : out std_logic; --! data available to be sent by buffer
        m_tready : in std_logic;  --! slave ready to receive data
        m_tdata  : out std_logic_vector(7 downto 0));
end UartReceiver;

architecture Behavioral of UartReceiver is
    component ClockDivN
        generic (
            N : positive);
        port (
            rst    : in std_logic;
            clk    : in std_logic;
            output : out std_logic);
    end component;

    signal receive_buffer, transmit_buffer : std_logic_vector(7 downto 0);
    signal baud_clk_8                      : std_logic; --! clock with frequency BAUD * 8
    signal receive_state                   : unsigned(7 downto 0);
begin
    clk_div : ClockDivN
    generic map(
        N => integer(CLK_FREQ / (BAUD * 8.0)))
    port map(
        rst    => not nrst,
        clk    => clk,
        output => baud_clk_8);

    receive_sm : process (clk) begin
        if rising_edge(clk) then
            if nrst = '0' then
                m_tvalid      <= '0';
                m_tdata       <= "00000000";
                receive_state <= "00000000";

            elsif baud_clk_8 = '1' then
                case to_integer(receive_state) is
                        -- txd_in has to be low for 4 cycles for a valid start signal
                    when 0 to 4 =>
                        receive_state <= receive_state + 1 when txd_in = '0' else "00000000";
                        -- sample txd_in every 8th cycle
                    when 12 | 20 | 28 | 36 | 44 | 52 | 60 | 68 =>
                        receive_state <= receive_state + 1;
                        -- shift data in LSB-first (right shift)
                        receive_buffer <= txd_in & receive_buffer(7 downto 1);
                        -- stop bit is another 8 cycles. double buffer result and start again
                    when 76 =>
                        receive_state <= "00000000";
                        m_tdata       <= receive_buffer;
                        m_tvalid      <= '1';
                    when others =>
                        receive_state <= receive_state + 1;
                end case;
            end if;

            cts <= m_tready;

            -- stream handshake
            if m_tready = '1' and m_tvalid = '1' then
                m_tvalid <= '0';
            end if;
        end if;
    end process;

end Behavioral;