--! UART receiver -> Stream buffer -> UART transmitter
--! Alexander Horstkötter 01.11.2022
--! successfully simulated 01.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UartRelay is
    port (
        CLK100MHZ    : in std_logic;
        CPU_RESETN   : in std_logic;
        UART_TXD_IN  : in std_logic;
        UART_CTS     : out std_logic;
        UART_RXD_OUT : out std_logic;
        UART_RTS     : in std_logic;
        LED          : out std_logic_vector(9 downto 0));
end entity;

architecture structural of UartRelay is
    component UartReceiver
        generic (
            BAUD : real := 9600.0);
        port (
            clk, nrst : in std_logic;
            -- UART
            txd_in : in std_logic;
            cts    : out std_logic; -- this device is ready to receive
            -- AXI4-stream master
            m_tvalid : out std_logic; -- data available to be sent by buffer
            m_tready : in std_logic;  -- slave ready to receive data
            m_tdata  : out std_logic_vector(7 downto 0));
    end component;

    component StreamBuffer
        generic (
            BUFFER_BITS : positive := 10);
        port (
            clk, nrst : in std_logic;
            s_tvalid  : in std_logic;  -- data available from master
            s_tready  : out std_logic; -- data ready to be received by buffer
            s_tdata   : in std_logic_vector(7 downto 0);
            m_tvalid  : out std_logic; -- data available to be sent by buffer
            m_tready  : in std_logic;  -- slave ready to receive data
            m_tdata   : out std_logic_vector(7 downto 0);
            size      : out unsigned(BUFFER_BITS - 1 downto 0));
    end component;

    component UartTransmitter
        generic (
            BAUD     : real := 9600.0;
            CLK_FREQ : real := 100000000.0);
        port (
            clk, nrst : in std_logic;
            -- UART
            rts     : in std_logic; -- request to send. other device is ready to receive
            rxd_out : out std_logic;
            -- AXI4-stream slave
            s_tvalid : in std_logic;  -- data available from master
            s_tready : out std_logic; -- data ready to be received
            s_tdata  : in std_logic_vector(7 downto 0));
    end component;

    -- receiver -> fifo
    signal in_tvalid, in_tready : std_logic;
    signal in_tdata             : std_logic_vector(7 downto 0);
    -- fifo -> transmitter
    signal out_tvalid, out_tready : std_logic;
    signal out_tdata              : std_logic_vector(7 downto 0);
begin

    receive : UartReceiver
    generic map(
        BAUD => 9600.0)
    port map(
        clk      => CLK100MHZ,
        nrst     => CPU_RESETN,
        txd_in   => UART_TXD_IN,
        cts      => UART_CTS,
        m_tvalid => in_tvalid,
        m_tready => in_tready,
        m_tdata  => in_tdata);

    fifo : StreamBuffer
    generic map(
        BUFFER_BITS => 10)
    port map(
        clk                    => CLK100MHZ,
        nrst                   => CPU_RESETN,
        s_tvalid               => in_tvalid,
        s_tready               => in_tready,
        s_tdata                => in_tdata,
        m_tvalid               => out_tvalid,
        m_tready               => out_tready,
        m_tdata                => out_tdata,
        std_logic_vector(size) => LED);

    transmit : UartTransmitter
    generic map(
        BAUD => 9600.0)
    port map(
        clk      => CLK100MHZ,
        nrst     => CPU_RESETN,
        rxd_out  => UART_RXD_OUT,
        rts      => UART_RTS,
        s_tvalid => out_tvalid,
        s_tready => out_tready,
        s_tdata  => out_tdata
    );

end structural;