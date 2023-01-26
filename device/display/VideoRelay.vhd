--! VideoRelay.vhd
--! Alexander Horstkötter 13.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VideoRelay is
    port (
        CLK100MHZ           : in std_logic;
        CPU_RESETN          : in std_logic;
        VGA_R, VGA_G, VGA_B : out std_logic_vector(3 downto 0);
        VGA_VS, VGA_HS      : out std_logic; --! low active
        UART_TXD_IN         : in std_logic;
        UART_CTS            : out std_logic);
end entity;

architecture behavioral of VideoRelay is
    -- component PixelClockGen is
    --     port (
    --         clk_logic : out std_logic;
    --         clk_pixel : out std_logic;
    --         locked    : out std_logic;
    --         reset     : in std_logic;
    --         clk100mhz : in std_logic
    --     );
    -- end component;

    component TextRenderer480p is
        generic (
            TEXT_W : integer := 80;
            TEXT_H : integer := 42);
        port (
            nrst                : in std_logic;
            clk100mhz           : in std_logic;
            s_tvalid            : in std_logic;
            s_taddr             : in integer range 0 to (TEXT_W * TEXT_H) - 1;
            s_tdata             : in std_logic_vector(7 downto 0);
            vga_r, vga_g, vga_b : out std_logic_vector(3 downto 0);
            vga_vs, vga_hs      : out std_logic); --! low active
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

    constant TEXT_W : integer := 20;
    constant TEXT_H : integer := 10;

    signal locked               : std_logic;
    signal clk_logic, clk_pixel : std_logic;

    signal ascii_addr  : integer range 0 to (TEXT_W * TEXT_H) - 1;
    signal ascii       : std_logic_vector(7 downto 0);
    signal ascii_valid : std_logic;
begin
    -- clk_gen : PixelClockGen
    -- port map(
    --     clk_logic => clk_logic,
    --     clk_pixel => clk_pixel,
    --     locked    => locked,
    --     reset     => CPU_RESETN,
    --     clk100mhz => CLK100MHZ);

    locked    <= CPU_RESETN;
    clk_logic <= CLK100MHZ;

    receiver : UartReceiver
    generic map(
        BAUD => 9600.0)
    port map(
        nrst     => locked,
        clk      => clk_logic,
        txd_in   => UART_TXD_IN,
        cts      => UART_CTS,
        m_tvalid => ascii_valid,
        m_tready => '1',
        m_tdata  => ascii);

    renderer : TextRenderer480p
    port map(
        nrst      => locked,
        clk100mhz => clk_logic,
        s_tvalid  => ascii_valid,
        s_taddr   => ascii_addr,
        s_tdata   => ascii,
        vga_r     => VGA_R,
        vga_g     => VGA_G,
        vga_b     => VGA_B,
        vga_hs    => VGA_HS,
        vga_vs    => VGA_VS);

    process (clk_logic) begin
        if rising_edge(clk_logic) then
            if locked = '0' then
                ascii_addr <= 0;
            else
                if ascii_valid = '1' then
                    if ascii_addr < (TEXT_W * TEXT_H) - 1 then
                        ascii_addr <= ascii_addr + 1;
                    else
                        ascii_addr <= 0;
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture;