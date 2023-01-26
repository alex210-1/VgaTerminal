--! SccbTester.vhd
--! Alexander Horstkötter 05.01.2023
--! used to debug the SCCB hardware
--! register address and data are set with the switches, pressing BTNC writes to that address,
--! pressing BTNU reads from that address.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SccbTester is
    port (
        CLK100MHZ  : in std_logic;
        CPU_RESETN : in std_logic;

        SW   : in std_logic_vector(15 downto 0); --! sub_address & data
        LED  : out std_logic_vector(7 downto 0); --! data
        BTNC : in std_logic;                     --! write to address
        BTNU : in std_logic;                     --! read from address

        CAM_NRST : out std_logic;
        CAM_XCLK : out std_logic; --! 6.25 MHz out
        CAM_SIOC : out std_logic;
        CAM_SIOD : inout std_logic);
end entity;

architecture behavioral of SccbTester is
    component SccbBus is
        port (
            clk, nrst  : in std_logic;
            bus_ready  : out std_logic; --! high when able to receive data. handshakes with send_valid
            send_valid : in std_logic;  --! master has data to be transmitted (either read or write)
            read_flag  : in std_logic;  --! when high a read operation is performed, else write
            read_valid : out std_logic; --! data is valid until next transmittion start

            addr       : in std_logic_vector(6 downto 0);  --! slave address
            sub_addr   : in std_logic_vector(7 downto 0);  --! register address
            write_data : in std_logic_vector(7 downto 0);  --! data to be writen to sub_addr
            read_data  : out std_logic_vector(7 downto 0); --! data read from sub_addr

            sio_c : out std_logic;    --! SCCB clock signal (100kHz max)
            sio_d : inout std_logic); --! SCCB data signal (tristate) 
    end component;

    constant ADDR : std_logic_vector(6 downto 0) := "0011110";

    signal clk_div      : unsigned(3 downto 0);
    signal debounce_div : unsigned(19 downto 0); --! divide to ~100Hz

    signal bus_ready  : std_logic;
    signal send_valid : std_logic;
    signal read_flag  : std_logic;
    signal read_valid : std_logic;
    signal read_data  : std_logic_vector(7 downto 0);

    signal btn_write, btn_write_last : std_logic;
    signal btn_read, btn_read_last   : std_logic;
begin
    DUT : SccbBus
    port map(
        clk        => CLK100MHZ,
        nrst       => CPU_RESETN,
        send_valid => send_valid,
        read_flag  => read_flag,
        read_valid => read_valid,
        addr       => ADDR,
        sub_addr   => SW(15 downto 8),
        write_data => SW(7 downto 0),
        read_data  => read_data,
        sio_c      => CAM_SIOC,
        sio_d      => CAM_SIOD);

    CAM_XCLK <= clk_div(3);
    CAM_NRST <= CPU_RESETN;

    gen_xclk : process (CLK100MHZ) begin
        if rising_edge(CLK100MHZ) then
            if CPU_RESETN = '0' then
                clk_div <= "0000";
            else
                clk_div <= clk_div + 1;
            end if;
        end if;
    end process;

    debounce : process (CLK100MHZ) begin
        if rising_edge(CLK100MHZ) then
            if CPU_RESETN = '0' then
                debounce_div <= (others => '0');
                btn_write    <= '0';
                btn_read     <= '0';
            else
                debounce_div <= debounce_div + 1;

                if debounce_div = 0 then
                    btn_write <= BTNC;
                    btn_read  <= BTNU;
                end if;
            end if;
        end if;
    end process;

    control : process (CLK100MHZ) begin
        if rising_edge(CLK100MHZ) then
            if CPU_RESETN = '0' then
                btn_write_last <= '0';
                btn_read_last  <= '0';
                send_valid     <= '0';
                read_flag      <= '0';
            else
                -- detect button press posedge
                if btn_write = '1' and btn_write_last = '0' then
                    send_valid <= '1';
                    read_flag  <= '0';
                elsif btn_read = '1' and btn_read_last = '0' then
                    send_valid <= '1';
                    read_flag  <= '1';
                else
                    send_valid <= '0';
                    read_flag  <= '0';
                end if;

                -- receive data
                if read_valid = '1' then
                    LED <= read_data;
                end if;

                btn_write_last <= btn_write;
                btn_read_last  <= btn_read;
            end if;
        end if;
    end process;

end architecture;