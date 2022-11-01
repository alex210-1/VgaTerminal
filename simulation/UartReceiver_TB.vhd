library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UartReceiver_TB is
end entity;

architecture test of UartReceiver_TB is
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

    constant message : std_logic_vector(7 downto 0) := "10011001";

    signal clk, nrst        : std_logic := '0';
    signal txd_in, m_tready : std_logic := '1';
    signal cts, m_tvalid    : std_logic;
    signal m_tdata          : std_logic_vector(7 downto 0);
begin
    DUT : UartReceiver
    generic map(
        BAUD => 1000000.0)
    port map(
        clk      => clk,
        nrst     => nrst,
        txd_in   => txd_in,
        cts      => cts,
        m_tvalid => m_tvalid,
        m_tready => m_tready,
        m_tdata  => m_tdata);

    gen_clk : process begin
        wait for 5 ps;
        clk <= not clk;
    end process;

    gen_data : process begin
        wait for 5 ns;
        txd_in <= '0';

        for i in 0 to 7 loop
            wait for 1 ns;
            txd_in <= message(i);
        end loop;

        wait for 1 ns;
        txd_in <= '1';
    end process;

    gen_stim : process begin
        wait for 100 ps;
        nrst <= '1';

        wait for 100 ms;
    end process;

end architecture;