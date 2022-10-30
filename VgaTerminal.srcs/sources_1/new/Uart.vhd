library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Uart is
    port (
        clk, nrst: in std_logic;
        txd_in, rts: in std_logic;
        rxd_out, cts: out std_logic;
        -- AXI4-stream slave
        s_tvalid: in std_logic;                         -- data available from master
        s_tready: out std_logic;                        -- data ready to be received by buffer
        s_tdata: in std_logic_vector(7 downto 0);
        -- AXI4-stream master
        m_tvalid: out std_logic;                        -- data available to be sent by buffer
        m_tready: in std_logic;                         -- slave ready to receive data
        m_tdata: out std_logic_vector(7 downto 0));
end Uart;

architecture Behavioral of Uart is
begin


end Behavioral;
