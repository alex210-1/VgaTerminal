library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Uart is
    port (
        clk, rst: in std_logic;
        txd_in, rts: in std_logic;
        rxd_out, cts: out std_logic);
end Uart;

architecture Behavioral of Uart is

begin


end Behavioral;
