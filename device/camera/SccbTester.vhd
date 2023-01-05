--! SccbTester.vhd
--! Alexander Horstkötter 05.01.2023

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SccbTester is
    port (
        CLK100MHZ  : in std_logic;
        CPU_RESETN : in std_logic;

        SW   : in std_logic_vector(15 downto 0); --! address & data
        LED  : out std_logic_vector(7 downto 0); --! data
        BTNC : in std_logic;                     --! write to address
        BTNU : in std_logic;                     --! read from address

        CAM_XCLK : out std_logic; --! 25 MHz out
        CAM_SIOC : out std_logic;
        CAM_SIOD : inout std_logic);
end entity;

architecture behavioral of SccbTester is
    signal clk_div : unsigned(1 downto 0);
begin
    CAM_XCLK <= clk_div(1);

    gen_xclk : process (CLK100MHZ) begin
        if rising_edge(CLK100MHZ) then
            if CPU_RESETN = '0' then
                clk_div <= "00";
            else
                clk_div <= clk_div + 1;
            end if;
        end if;
    end process;
end architecture;