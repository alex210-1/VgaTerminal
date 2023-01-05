--! BlinkerStateMachine.vhd
--! Alexander Horstkötter 19.12.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BlinkerStateMachine is
    port (
        clk, nrst : in std_logic;
        L, R, W   : in std_logic;
        light     : out std_logic_vector(5 downto 0));
end entity;

architecture behavioral of BlinkerStateMachine is
    type state_type is (IDLE, WARN, L1, L2, L3, R1, R2, R3);
    signal state, next_state : state_type;
begin
    transition : process (all) begin
        next_state <= state;

        if state /= WARN and W = '1' then
            next_state <= WARN;
        else
            case state is
                when IDLE =>
                    if L = '1' and R = '1' then
                        -- if you manage to blink in both directions,
                        -- something is very wrong with your car => warn
                        next_state <= WARN;
                    elsif L = '1' then
                        next_state <= L1;
                    elsif R = '1' then
                        next_state <= R1;
                    end if;
                when L1 =>
                    next_state <= L2 when L = '1' else IDLE;
                when L2 =>
                    next_state <= L3 when L = '1' else IDLE;
                when R1 =>
                    next_state <= R2 when R = '1' else IDLE;
                when R2 =>
                    next_state <= R3 when R = '1' else IDLE;
                when WARN | L3 | R3 =>
                    next_state <= IDLE;
            end case;
        end if;
    end process;

    storage : process (clk, nrst) begin
        if nrst = '0' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    with state select light <=
        "000000" when IDLE,
        "111111" when WARN,
        "001000" when L1,
        "011000" when L2,
        "111000" when L3,
        "000100" when R1,
        "000110" when R2,
        "000111" when R3;

end architecture;