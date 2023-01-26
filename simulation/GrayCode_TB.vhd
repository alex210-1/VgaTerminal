--! GrayCode_TB.vhd
--! Alexander Horstkötter 19.01.2023

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity GrayCode_TB is
end entity;

architecture behavioral of GrayCode_TB is
    component GrayCode is
        port (
            bin  : in std_logic_vector(3 downto 0);
            gray : out std_logic_vector(3 downto 0));
    end component;

    signal bin, gray : std_logic_vector(3 downto 0);
begin
    DUT : GrayCode
    port map(
        bin  => bin,
        gray => gray);

    gen_stim : process begin
        bin <= "0000";

        for i in 0 to 15 loop
            wait for 1 ns;

            bin <= std_logic_vector(to_unsigned(i, 4));
        end loop;

        wait;
    end process;
end architecture;