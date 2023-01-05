--! SccbBus_TB.vhd
--! Alexander Horstkötter 29.12.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SccbBus_TB is
end entity;

architecture behavioral of SccbBus_TB is
    component SccbBus is
        port (
            clk, nrst  : in std_logic;
            bus_ready  : out std_logic; --! high when able to receive data. handshakes with send_valid
            send_valid : in std_logic;  --! master has data to be transmitted (either read or write)
            read_flag  : in std_logic;  --! when high a read operation is performed, else write
            read_valid : out std_logic; --! high for one tick when read_data is received

            addr       : in std_logic_vector(6 downto 0);  --! slave address
            sub_addr   : in std_logic_vector(7 downto 0);  --! register address
            write_data : in std_logic_vector(7 downto 0);  --! data to be writen to sub_addr
            read_data  : out std_logic_vector(7 downto 0); --! data read from sub_addr

            sio_c : out std_logic;    --! SCCB clock signal (100kHz max)
            sio_d : inout std_logic); --! SCCB data signal (tristate) 
    end component;

    signal clk        : std_logic := '1';
    signal nrst       : std_logic := '0';
    signal bus_ready  : std_logic;
    signal send_valid : std_logic;
    signal read_flag  : std_logic;
    signal read_valid : std_logic;

    signal addr       : std_logic_vector(6 downto 0);
    signal sub_addr   : std_logic_vector(7 downto 0);
    signal write_data : std_logic_vector(7 downto 0);
    signal read_data  : std_logic_vector(7 downto 0);

    signal sio_c : std_logic;
    signal sio_d : std_logic := 'Z';

begin

    DUT : SccbBus
    port map(
        clk        => clk,
        nrst       => nrst,
        bus_ready  => bus_ready,
        send_valid => send_valid,
        read_flag  => read_flag,
        read_valid => read_valid,
        addr       => addr,
        sub_addr   => sub_addr,
        write_data => write_data,
        read_data  => read_data,
        sio_c      => sio_c,
        sio_d      => sio_d);

    gen_stim : process begin
        wait for 10 ns;
        nrst <= '1';

        -- write test
        wait for 100 ns;
        send_valid <= '1';
        read_flag  <= '0';
        addr       <= "1001100";
        sub_addr   <= "11001100";
        write_data <= "01010101";

        wait for 100 ns;
        send_valid <= '0';

        -- read test
        wait for 400 us;
        read_flag  <= '1';
        send_valid <= '1';

        wait for 100 ns;
        send_valid <= '0';

        wait for 280 us;
        sio_d <= '0';
        wait for 40 us;
        sio_d <= '1';
        wait for 40 us;
        sio_d <= 'Z';

        wait;
    end process;

    gen_clk : process begin
        wait for 5 ns;
        clk <= not clk;
    end process;

end architecture;