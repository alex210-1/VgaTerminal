--! KeyboardController_TB.vhd
--! Alexander Horstkötter 03.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.keycodes.all;

entity KeyboardController_TB is
end entity;

architecture test of KeyboardController_TB is
    component KeyboardController is
        port (
            clk, nrst : in std_logic;
            -- scancode input
            s_tvalid      : in std_logic;
            s_tdata_code  : in std_logic_vector(15 downto 0);
            s_tdata_break : in std_logic;
            -- ascii output
            m_ascii_tvalid : out std_logic;
            m_ascii_tdata  : out std_logic_vector(7 downto 0);
            -- command output
            m_cmd_tvalid : out std_logic;
            m_cmd_tdata  : out KeyCommand);
    end component;

    -- MSB is break flag
    type KeyCodes is array(0 to 14) of std_logic_vector(16 downto 0);
    constant key_codes : KeyCodes := (
        '0' & x"0025", -- make 4
        '1' & x"0025", -- break 4
        '0' & x"0012", -- make shift
        '0' & x"0033", -- make h
        '1' & x"0012", -- break shift
        '1' & x"0033", -- break h
        '0' & x"005A", -- make enter
        '0' & x"0058", -- make caps lock
        '0' & x"0033", -- make h
        '0' & x"0012", -- make shift
        '1' & x"0033", -- break h
        '0' & x"0033", -- make h
        '0' & x"0058", -- make caps lock
        '1' & x"0033", -- break h
        '1' & x"0012"  -- break shift
    );

    signal clk, nrst                        : std_logic := '0';
    signal in_tvalid, in_tdata_break        : std_logic := '0';
    signal in_tdata_code                    : std_logic_vector(15 downto 0);
    signal out_ascii_tvalid, out_cmd_tvalid : std_logic;
    signal out_ascii_tdata                  : std_logic_vector(7 downto 0);
    signal out_cmd_tdata                    : KeyCommand;
    signal out_char                         : character;
begin
    DUT : KeyboardController
    port map(
        clk            => clk,
        nrst           => nrst,
        s_tvalid       => in_tvalid,
        s_tdata_code   => in_tdata_code,
        s_tdata_break  => in_tdata_break,
        m_ascii_tvalid => out_ascii_tvalid,
        m_ascii_tdata  => out_ascii_tdata,
        m_cmd_tvalid   => out_cmd_tvalid,
        m_cmd_tdata    => out_cmd_tdata);

    out_char <= character'val(to_integer(unsigned(out_ascii_tdata)));

    gen_clk : process begin
        wait for 5 ps;
        clk <= not clk;
    end process;

    gen_stim : process begin
        wait for 20 ps;
        nrst <= '1';
        wait for 20 ps;

        for i in key_codes'range loop
            in_tvalid      <= '1';
            in_tdata_code  <= key_codes(i)(15 downto 0);
            in_tdata_break <= key_codes(i)(16);

            wait for 10 ps;
            in_tvalid <= '0';
            wait for 10 ps;
        end loop;
    end process;
end architecture;