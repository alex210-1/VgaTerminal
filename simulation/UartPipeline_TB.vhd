--! UART transmitter -> UART receiver -> Stream buffer
--! Alexander Horstkötter 01.11.2022
--! successfully simulated 01.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UartPipeline_TB is
end entity;

architecture test of UartPipeline_TB is
    component UartTransmitter is
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

    component UartReceiver is
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

    component StreamBuffer is
        generic (
            BUFFER_BITS : positive := 10);
        port (
            clk, nrst : in std_logic;
            s_tvalid  : in std_logic;  -- data available from master
            s_tready  : out std_logic; -- data ready to be received by buffer
            s_tdata   : in std_logic_vector(7 downto 0);
            m_tvalid  : out std_logic; -- data available to be sent by buffer
            m_tready  : in std_logic;  -- slave ready to receive data
            m_tdata   : out std_logic_vector(7 downto 0));
    end component;

    signal clk, nrst              : std_logic := '0';
    signal rxtx, rtscts           : std_logic;
    signal in_tvalid, in_tready   : std_logic;
    signal in_tdata               : std_logic_vector(7 downto 0);
    signal out_tvalid, out_tready : std_logic;
    signal out_tdata              : std_logic_vector(7 downto 0);
begin

    transmit : UartTransmitter
    generic map(
        BAUD => 1000000.0)
    port map(
        clk      => clk,
        nrst     => nrst,
        rxd_out  => rxtx,
        rts      => rtscts,
        s_tvalid => in_tvalid,
        s_tready => in_tready,
        s_tdata  => in_tdata
    );

    receive : UartReceiver
    generic map(
        BAUD => 1000000.0)
    port map(
        clk      => clk,
        nrst     => nrst,
        txd_in   => rxtx,
        cts      => rtscts,
        m_tvalid => out_tvalid,
        m_tready => out_tready,
        m_tdata  => out_tdata);

    store : StreamBuffer
    generic map(
        BUFFER_BITS => 4)
    port map(
        clk      => clk,
        nrst     => nrst,
        s_tvalid => out_tvalid,
        s_tready => out_tready,
        s_tdata  => out_tdata,
        m_tready => '0');

    gen_clk : process begin
        wait for 5 ps;
        clk <= not clk;
    end process;

    gen_stim : process begin
        wait for 20 ps;
        nrst <= '1';

        for i in 1 to 10 loop
            wait for 5 ns;
            in_tdata <= std_logic_vector(to_unsigned(i, 8));

            in_tvalid <= '1';
            wait for 5 ns;
            in_tvalid <= '0';
        end loop;

        wait for 100 ms;
    end process;
end test;