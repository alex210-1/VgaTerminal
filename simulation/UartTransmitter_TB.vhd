library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UartTransmitter_TB is
end entity;

architecture test of UartTransmitter_TB is
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

    constant message : std_logic_vector(7 downto 0) := "10011001";

    signal clk, nrst          : std_logic := '0';
    signal rxd_out, rts       : std_logic := '1';
    signal s_tvalid, s_tready : std_logic;
    signal s_tdata            : std_logic_vector(7 downto 0);
begin
    DUT : UartTransmitter
    generic map(
        BAUD => 1000000.0)
    port map(
        clk      => clk,
        nrst     => nrst,
        rxd_out  => rxd_out,
        rts      => rts,
        s_tvalid => s_tvalid,
        s_tready => s_tready,
        s_tdata  => s_tdata);

    gen_clk : process begin
        wait for 5 ps;
        clk <= not clk;
    end process;

    gen_stim : process begin
        wait for 100 ps;
        nrst <= '1';

        wait for 1 ns;
        s_tdata  <= message;
        s_tvalid <= '1';

        wait for 5 ns;
        rts <= '0';

        wait for 6 ns;
        rts <= '1';

        wait for 100 ms;
    end process;

end architecture;