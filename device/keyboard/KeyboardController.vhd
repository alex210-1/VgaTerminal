--! KeyboardController.vhd
--! takes keyboard events, manages keyboard state and emits either ascii characters
--! or command codes
--!
--! Alexander Horstkötter 03.11.2022
--! successfully simulated 04.11.2022
--! fixed caps-lock bug 05.11.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.keycodes.all;

entity KeyboardController is
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
end entity;

architecture behavioral of KeyboardController is
    signal l_shift_pressed, r_shift_pressed, l_ctrl_pressed, r_ctrl_pressed : std_logic;
    signal alt_pressed, alt_gr_pressed, ctrl_pressed                        : std_logic;
    signal caps_lock_active, shift_active                                   : std_logic;
begin
    ctrl_pressed <= l_ctrl_pressed or r_ctrl_pressed;
    shift_active <= (l_shift_pressed or r_shift_pressed) xor caps_lock_active;

    process (clk)
        --! send a single character to ascii output (when not breaking)
        procedure send_ascii(constant char : character) is begin
            if s_tdata_break = '0' then
                m_ascii_tvalid <= '1';
                m_ascii_tdata  <= std_logic_vector(to_unsigned(character'pos(char), 8));
            end if;
        end procedure;

        --! send a single character to ascii output (when not breaking)
        procedure send_cmd(constant cmd : KeyCommand) is begin
            if s_tdata_break = '0' then
                m_cmd_tvalid <= '1';
                m_cmd_tdata  <= cmd;
            end if;
        end procedure;

        --! send either a lower or upper case character depending on shift state
        procedure send_ascii_shift(constant lower, upper : character) is begin
            if shift_active = '1' then
                send_ascii(upper);
            else
                send_ascii(lower);
            end if;
        end procedure;

        --! send either a lower, upper or alternate character
        procedure send_ascii_shift_alt(constant lower, upper, alt : character) is begin
            if alt_gr_pressed = '1' then
                if shift_active = '0' then
                    send_ascii(alt);
                end if;
            else
                if shift_active = '1' then
                    send_ascii(upper);
                else
                    send_ascii(lower);
                end if;
            end if;
        end procedure;
    begin
        if rising_edge(clk) then
            if nrst = '0' then
                l_shift_pressed  <= '0';
                r_shift_pressed  <= '0';
                l_ctrl_pressed   <= '0';
                r_ctrl_pressed   <= '0';
                alt_pressed      <= '0';
                alt_gr_pressed   <= '0';
                caps_lock_active <= '0';
            else
                if m_ascii_tvalid = '1' then
                    m_ascii_tvalid <= '0';
                end if;
                if m_cmd_tvalid = '1' then
                    m_cmd_tvalid <= '0';
                end if;

                -- handle incoming key events
                if s_tvalid then
                    case scancode_to_keycode(s_tdata_code) is
                            -- control keys
                        when KEY_L_SHIFT   => l_shift_pressed <= not s_tdata_break;
                        when KEY_R_SHIFT   => l_shift_pressed <= not s_tdata_break;
                        when KEY_L_CTRL    => l_ctrl_pressed   <= not s_tdata_break;
                        when KEY_R_CTRL    => r_ctrl_pressed   <= not s_tdata_break;
                        when KEY_ALT       => alt_pressed         <= not s_tdata_break;
                        when KEY_ALT_GR    => alt_gr_pressed   <= not s_tdata_break;
                        when KEY_CAPS_LOCK =>
                            if not s_tdata_break then
                                caps_lock_active <= not caps_lock_active;
                            end if;

                            -- first row TODO
                        when KEY_ESC    => send_cmd(CMD_ESCAPE);
                        when KEY_DELETE => send_cmd(CMD_DELETE);
                            -- seconds row 
                        when KEY_CIRCUMFLEX   => send_ascii_shift('^', character'val(176));
                        when KEY_1            => send_ascii_shift('1', '!');
                        when KEY_2            => send_ascii_shift_alt('2', '"', character'val(178));
                        when KEY_3            => send_ascii_shift_alt('3', character'val(167), character'val(179));
                        when KEY_4            => send_ascii_shift('4', character'val(36));
                        when KEY_5            => send_ascii_shift('5', '%');
                        when KEY_6            => send_ascii_shift('6', '&');
                        when KEY_7            => send_ascii_shift_alt('7', '&', '{');
                        when KEY_8            => send_ascii_shift_alt('8', '(', '[');
                        when KEY_9            => send_ascii_shift_alt('9', ')', ']');
                        when KEY_0            => send_ascii_shift_alt('0', '=', '}');
                        when KEY_QUESTIONMARK => send_ascii_shift_alt(character'val(223), '?', '\');
                        when KEY_BACKTICK     => send_ascii_shift(character'val(180), '`');
                        when KEY_BACKSPACE    => send_cmd(CMD_BACKSPACE);
                        when KEY_NUM_DIV      => send_ascii('/');
                        when KEY_NUM_MUL      => send_ascii('*');
                        when KEY_NUM_MINUS    => send_ascii('-');
                            -- third row
                        when KEY_TAB      => send_cmd(CMD_TAB);
                        when KEY_Q        => send_ascii_shift_alt('q', 'Q', '@');
                        when KEY_W        => send_ascii_shift('w', 'W');
                        when KEY_E        => send_ascii_shift('e', 'E');
                        when KEY_R        => send_ascii_shift('r', 'R');
                        when KEY_T        => send_ascii_shift('t', 'T');
                        when KEY_Z        => send_ascii_shift('z', 'Z');
                        when KEY_U        => send_ascii_shift('u', 'U');
                        when KEY_I        => send_ascii_shift('i', 'I');
                        when KEY_O        => send_ascii_shift('o', 'O');
                        when KEY_P        => send_ascii_shift('p', 'P');
                        when KEY_UE       => send_ascii_shift(character'val(252), character'val(220));
                        when KEY_PLUS     => send_ascii_shift_alt('+', '*', '~');
                        when KEY_HASH     => send_ascii_shift('#', character'val(39));
                        when KEY_NUM_7    => send_ascii('7');
                        when KEY_NUM_8    => send_ascii('8');
                        when KEY_NUM_9    => send_ascii('9');
                        when KEY_NUM_PLUS => send_ascii('+');
                            -- fourth row
                        when KEY_A     => send_ascii_shift('a', 'A');
                        when KEY_S     => send_ascii_shift('s', 'S');
                        when KEY_D     => send_ascii_shift('d', 'D');
                        when KEY_F     => send_ascii_shift('f', 'F');
                        when KEY_G     => send_ascii_shift('g', 'G');
                        when KEY_H     => send_ascii_shift('h', 'H');
                        when KEY_J     => send_ascii_shift('j', 'J');
                        when KEY_K     => send_ascii_shift('k', 'K');
                        when KEY_L     => send_ascii_shift('l', 'L');
                        when KEY_OE    => send_ascii_shift(character'val(246), character'val(214));
                        when KEY_AE    => send_ascii_shift(character'val(228), character'val(196));
                        when KEY_ENTER => send_cmd(CMD_ENTER);
                        when KEY_NUM_4 => send_ascii('4');
                        when KEY_NUM_5 => send_ascii('5');
                        when KEY_NUM_6 => send_ascii('6');
                            -- fifth row
                        when KEY_Y         => send_ascii_shift('y', 'Y');
                        when KEY_X         => send_ascii_shift('x', 'X');
                        when KEY_C         => send_ascii_shift('c', 'C');
                        when KEY_V         => send_ascii_shift('v', 'V');
                        when KEY_B         => send_ascii_shift('b', 'B');
                        when KEY_N         => send_ascii_shift('n', 'N');
                        when KEY_M         => send_ascii_shift('m', 'M');
                        when KEY_COMMA     => send_ascii_shift(',', ';');
                        when KEY_PERIOD    => send_ascii_shift('.', ':');
                        when KEY_MINUS     => send_ascii_shift('-', '_');
                        when KEY_NUM_1     => send_ascii('1');
                        when KEY_NUM_2     => send_ascii('2');
                        when KEY_NUM_3     => send_ascii('3');
                        when KEY_NUM_ENTER => send_cmd(CMD_ENTER);
                            -- sixth row
                        when KEY_L_WIN       => send_cmd(CMD_WIN);
                        when KEY_SPACE       => send_ascii(' ');
                        when KEY_SMALLER     => send_ascii_shift_alt('<', '>', '|');
                        when KEY_ARROW_LEFT  => send_cmd(CMD_LEFT);
                        when KEY_ARROW_UP    => send_cmd(CMD_UP);
                        when KEY_ARROW_DOWN  => send_cmd(CMD_DOWN);
                        when KEY_ARROW_RIGHT => send_cmd(CMD_RIGHT);
                        when KEY_NUM_0       => send_ascii('0');
                        when KEY_NUM_DOT     => send_ascii(',');
                        when others          => -- nothing
                    end case;
                end if;
            end if;
        end if;
    end process;
end architecture;