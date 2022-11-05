--! KeyboardRelay.vhd
--! PS/2 Receiver -> ScancodeDecoder -> KeyboardController
--! -(ascii)-> StreamBuffer -> UartTransmitter
--! Alexander Horstkötter 03.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.keycodes.all;

entity KeyboardRelay is
    port (
        CLK100MHZ    : in std_logic;
        CPU_RESETN   : in std_logic;
        UART_RXD_OUT : out std_logic;
        UART_RTS     : in std_logic;
        PS2_CLK      : in std_logic;
        PS2_DATA     : in std_logic;
        LED          : out std_logic_vector(15 downto 0));
end entity;

architecture behavioral of KeyboardRelay is
    component Ps2Receiver is
        port (
            clk, nrst         : in std_logic;
            ps2_clk, ps2_data : in std_logic;
            m_tvalid          : out std_logic;
            m_tdata           : out std_logic_vector(7 downto 0));
    end component;

    component ScancodeDecoder is
        port (
            clk, nrst     : in std_logic;
            s_tvalid      : in std_logic;
            s_tdata       : in std_logic_vector(7 downto 0);
            m_tvalid      : out std_logic;
            m_tdata_code  : out std_logic_vector(15 downto 0);
            m_tdata_break : out std_logic);
    end component;

    component KeyboardController is
        port (
            clk, nrst : in std_logic;
            -- scancode input
            s_tvalid      : in std_logic;
            s_tdata_code  : in std_logic_vector(15 downto 0);
            s_tdata_break : in std_logic;
            -- ascii output
            m_ascii_tvalid : out std_logic;
            m_ascii_tdata  : out std_logic_vector(7 downto 0);
            -- command output
            m_cmd_tvalid : out std_logic;
            m_cmd_tdata  : out KeyCommand);
    end component;

    component StreamBuffer is
        generic (
            BUFFER_BITS : positive := 10;
            type DATA_TYPE);
        port (
            clk, nrst : in std_logic;
            s_tvalid  : in std_logic;  -- data available from master
            s_tready  : out std_logic; -- data ready to be received by buffer
            s_tdata   : in DATA_TYPE;
            m_tvalid  : out std_logic; -- data available to be sent by buffer
            m_tready  : in std_logic;  -- slave ready to receive data
            m_tdata   : out DATA_TYPE;
            size      : out unsigned(BUFFER_BITS - 1 downto 0)); -- current fill level
    end component;

    component UartTransmitter is
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
    end component;

    -- Ps2Receiver
    signal scancode       : std_logic_vector(7 downto 0);
    signal scancode_valid : std_logic;
    -- SancodeDecoder
    signal keycode       : std_logic_vector(15 downto 0);
    signal keycode_break : std_logic;
    signal keycode_valid : std_logic;
    -- KeyboardController
    signal ascii       : std_logic_vector(7 downto 0);
    signal ascii_valid : std_logic;
    -- StreamBuffer
    signal ascii_buf       : std_logic_vector(7 downto 0);
    signal ascii_buf_valid : std_logic;
    signal ascii_buf_ready : std_logic;
    -- UartTransmitter
begin
    ps2_receiver : Ps2Receiver
    port map(
        clk      => CLK100MHZ,
        nrst     => CPU_RESETN,
        ps2_clk  => PS2_CLK,
        ps2_data => PS2_DATA,
        m_tvalid => scancode_valid,
        m_tdata  => scancode);

    scancode_decoder : ScancodeDecoder
    port map(
        clk           => CLK100MHZ,
        nrst          => CPU_RESETN,
        s_tvalid      => scancode_valid,
        s_tdata       => scancode,
        m_tvalid      => keycode_valid,
        m_tdata_code  => keycode,
        m_tdata_break => keycode_break);

    keyboard_controller : KeyboardController
    port map(
        clk            => CLK100MHZ,
        nrst           => CPU_RESETN,
        s_tvalid       => keycode_valid,
        s_tdata_code   => keycode,
        s_tdata_break  => keycode_break,
        m_ascii_tvalid => ascii_valid,
        m_ascii_tdata  => ascii);

    stream_buffer : StreamBuffer
    generic map(
        BUFFER_BITS => 4,
        DATA_TYPE   => std_logic_vector(7 downto 0))
    port map(
        clk      => CLK100MHZ,
        nrst     => CPU_RESETN,
        s_tvalid => ascii_valid,
        s_tdata  => ascii,
        m_tvalid => ascii_buf_valid,
        m_tready => ascii_buf_ready,
        m_tdata  => ascii_buf);

    uart_transmitter : UartTransmitter
    generic map(
        BAUD     => 9600.0,
        CLK_FREQ => 100000000.0)
    port map(
        clk      => CLK100MHZ,
        nrst     => CPU_RESETN,
        s_tvalid => ascii_buf_valid,
        s_tready => ascii_buf_ready,
        s_tdata  => ascii_buf,
        rts      => UART_RTS,
        rxd_out  => UART_RXD_OUT);

    debug : process (CLK100MHZ) begin
        if rising_edge(CLK100MHZ) then
            if CPU_RESETN = '0' then
                LED <= (others => '0');
            else
                if keycode_valid = '1' then
                    LED <= keycode;
                end if;
            end if;
        end if;
    end process;

end architecture;