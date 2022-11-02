library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ps2Receiver_TB is
end entity;

architecture test of Ps2Receiver_TB is
    component Ps2Receiver
        port (
            clk, nrst         : in std_logic;
            ps2_clk, ps2_data : in std_logic;
            m_tready          : in std_logic;
            m_tvalid          : out std_logic;
            m_tdata           : out std_logic_vector(7 downto 0));
    end component;

    constant message : std_logic_vector(7 downto 0) := "10011001";

    signal clk, nrst          : std_logic := '0';
    signal ps2_clk, ps2_data  : std_logic := '1';
    signal m_tready, m_tvalid : std_logic;
    signal m_tdata            : std_logic_vector(7 downto 0);
begin
    DUT : Ps2Receiver
    port map(
        clk      => clk,
        nrst     => nrst,
        ps2_clk  => ps2_clk,
        ps2_data => ps2_data,
        m_tvalid => m_tvalid,
        m_tready => m_tready,
        m_tdata  => m_tdata);

    gen_clk : process begin
        wait for 5 ps;
        clk <= not clk;
    end process;

    gen_data : process begin
        wait for 100 ps;
        ps2_data <= '0'; -- start bit
        wait for 50 ps;
        ps2_clk <= '0';
        wait for 100 ps;
        ps2_clk <= '1';

        for i in 0 to 7 loop
            wait for 50 ps;
            ps2_data <= message(i);
            wait for 50 ps;
            ps2_clk <= '0';
            wait for 100 ps;
            ps2_clk <= '1';
        end loop;

        wait for 50 ps;
        ps2_data <= '1'; -- stop bit
        wait for 50 ps;
        ps2_clk <= '0';
        wait for 100 ps;
        ps2_clk <= '1';
    end process;

    gen_stim : process begin
        wait for 100 ps;
        nrst     <= '1';
        m_tready <= '0';

        wait for 2 ns;
        m_tready <= '1';

        wait for 100 ms;
    end process;

end architecture;