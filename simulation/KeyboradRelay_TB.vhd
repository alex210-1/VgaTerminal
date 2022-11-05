--! KeyboradRelay_TB.vhd
--! Alexander Horstkötter 05.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity KeyboradRelay_TB is
end entity;

architecture test of KeyboradRelay_TB is
    component KeyboardRelay is
        port (
            CLK100MHZ    : in std_logic;
            CPU_RESETN   : in std_logic;
            UART_RXD_OUT : out std_logic;
            UART_RTS     : in std_logic;
            PS2_CLK      : in std_logic;
            PS2_DATA     : in std_logic;
            LED          : out std_logic_vector(15 downto 0));
    end component;

    type ScanCodes is array(0 to 14) of std_logic_vector(7 downto 0);
    constant scan_codes : ScanCodes := (
        x"25", -- make 4
        x"25", -- break 4
        x"12", -- make shift
        x"33", -- make h
        x"12", -- break shift
        x"33", -- break h
        x"5A", -- make enter
        x"58", -- make caps lock
        x"33", -- make h
        x"12", -- make shift
        x"33", -- break h
        x"33", -- make h
        x"58", -- make caps lock
        x"33", -- break h
        x"12"  -- break shift
    );

    signal clk               : std_logic := '1';
    signal nrst              : std_logic := '0';
    signal ps2_clk, ps2_data : std_logic := '1';
    signal uart_rxd_out      : std_logic;
    signal uart_rts          : std_logic := '0'; -- low active
begin
    DUT : KeyboardRelay
    port map(
        CLK100MHZ    => clk,
        CPU_RESETN   => nrst,
        PS2_CLK      => ps2_clk,
        PS2_DATA     => ps2_data,
        UART_RXD_OUT => uart_rxd_out,
        UART_RTS     => uart_rts);

    gen_clk : process begin
        wait for 5 ns;
        clk <= not clk;
    end process;

    gen_stim : process
        variable frame : std_logic_vector(10 downto 0);
    begin
        wait for 100 ns;
        nrst <= '1';

        -- send PS/2 Frame
        for i in scan_codes'range loop
            -- stop, parity, data, start (LSB first)
            frame := "11" & scan_codes(i) & '0';

            for j in 0 to 10 loop
                wait for 25 us;
                ps2_data <= frame(j);
                wait for 25 us;
                ps2_clk <= '0';
                wait for 50 us;
                ps2_clk <= '1';
            end loop;

            wait for 200 us;
        end loop;

        wait for 100 ms;
    end process;
end architecture;