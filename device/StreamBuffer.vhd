--! FIFO Buffer between two AXI4-streams.
--! implements both a master (m_ signals) and a slave interface (s_signals).
--! implemented as a ringbuffer with 2^BUFFER_BITS size.
--! synchronous low-active reset.
--! should infer bram.
--!
--! https://www.kampis-elektroecke.de/2020/04/axi-stream-interface/
--! handshake occurs when both ready and valid are high. Data is clocked on handshake.
--!
--! Alexander Horstkoetter 30.10.2022
--! Simulated successfully 30.10.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity StreamBuffer is
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
end StreamBuffer;

architecture Behavioral of StreamBuffer is
    type BufferArray is array(2 ** BUFFER_BITS - 1 downto 0) of std_logic_vector(7 downto 0);

    signal data_buffer                 : BufferArray;
    signal read_pointer, write_pointer : unsigned(BUFFER_BITS - 1 downto 0);
    signal s_tready_int, m_tvalid_int  : std_logic;
begin
    s_tready <= s_tready_int;
    m_tvalid <= m_tvalid_int;

    -- ready to receive when buffer not full. buffer full if write_pointer = read_pointer - 1
    s_tready_int <= '0' when write_pointer + 1 = read_pointer or nrst = '0' else '1';

    -- ready to send when buffer not empty. buffer empty if read_pointer = write_pointer
    m_tvalid_int <= '0' when write_pointer = read_pointer or nrst = '0' else '1';

    rst_logic : process (clk) begin
        if rising_edge(clk) then
            if nrst = '0' then
                read_pointer  <= to_unsigned(0, BUFFER_BITS);
                write_pointer <= to_unsigned(0, BUFFER_BITS);
            else

                -- slave handshake
                if s_tready_int = '1' and s_tvalid = '1' then
                    data_buffer(to_integer(write_pointer)) <= s_tdata;
                    write_pointer                          <= write_pointer + 1;
                end if;

                -- master handshake
                if m_tready = '1' and m_tvalid_int = '1' then
                    m_tdata      <= data_buffer(to_integer(read_pointer));
                    read_pointer <= read_pointer + 1;
                end if;

            end if;
        end if;
    end process;

end Behavioral;