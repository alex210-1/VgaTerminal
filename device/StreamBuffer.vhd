--! FIFO Buffer between two AXI4-streams.
--! implements both a master (m_ signals) and a slave interface (s_signals).
--! implemented as a ringbuffer with 2^BUFFER_BITS size.
--! synchronous low-active reset.
--! should infer bram. TODO current implementation seems to be bad for synthesis
--!
--! https://www.kampis-elektroecke.de/2020/04/axi-stream-interface/
--! handshake occurs when both ready and valid are high. Data is clocked on handshake.
--!
--! Alexander Horstkoetter 30.10.2022
--! Simulated successfully 30.10.2022
--! change two pointers to one pointer + size 04.11.2022
--! fixed a bug that stalled the stream 05.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity StreamBuffer is
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
end entity;

architecture Behavioral of StreamBuffer is
    type BufferArray is array(2 ** BUFFER_BITS - 1 downto 0) of DATA_TYPE;

    signal data_buffer                 : BufferArray;
    signal read_pointer, write_pointer : unsigned(BUFFER_BITS - 1 downto 0);
begin

    -- ready to receive when buffer not full
    s_tready <= '0' when (and size = '1') or nrst = '0' else '1';
    -- ready to send when buffer not empty
    m_tvalid <= '0' when (or size = '0') or nrst = '0' else '1';

    m_tdata       <= data_buffer(to_integer(read_pointer));
    write_pointer <= read_pointer + size;

    process (clk) begin
        if rising_edge(clk) then
            if nrst = '0' then
                read_pointer <= to_unsigned(0, BUFFER_BITS);
                size         <= to_unsigned(0, BUFFER_BITS);
            else

                -- slave handshake -> write to buffer
                if s_tready = '1' and s_tvalid = '1' then
                    data_buffer(to_integer(write_pointer)) <= s_tdata;
                    size                                   <= size + 1;
                end if;

                -- master handshake - read from buffer
                if m_tready = '1' and m_tvalid = '1' then
                    read_pointer <= read_pointer + 1;
                    size         <= size - 1;
                end if;

            end if;
        end if;
    end process;

end Behavioral;