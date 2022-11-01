library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity StreamBuffer_TB is
end StreamBuffer_TB;

architecture Behavioral of StreamBuffer_TB is
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
            m_tdata   : out std_logic_vector(7 downto 0));
    end component;

    signal clk, nrst          : std_logic := '0';
    signal s_tready, m_tvalid : std_logic;
    signal s_tvalid, m_tready : std_logic                    := '0';
    signal s_tdata, m_tdata   : std_logic_vector(7 downto 0) := "00000000";
begin
    DUT : StreamBuffer
    generic map(
        BUFFER_BITS => 3)
    port map(
        clk      => clk,
        nrst     => nrst,
        s_tvalid => s_tvalid,
        s_tready => s_tready,
        s_tdata  => s_tdata,
        m_tvalid => m_tvalid,
        m_tready => m_tready,
        m_tdata  => m_tdata);

    gen_clk : process begin
        wait for 5 ps;
        clk <= not clk;
    end process;

    gen_stim : process begin
        wait for 20 ps;
        nrst <= '1';

        -- write data
        for i in 0 to 10 loop
            wait for 40 ps;
            s_tdata  <= std_logic_vector(to_unsigned(i + 10, 8));
            s_tvalid <= '1';
            wait for 10 ps;
            s_tvalid <= '0';
        end loop;

        -- read data
        m_tready <= '1';
        wait for 100 ms;
    end process;

end Behavioral;