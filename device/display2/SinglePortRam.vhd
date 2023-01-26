--! SinglePortRam.vhd
--! Alexander Horstkötter 16.01.2023

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SinglePortRam is
    generic (
        DATA_WIDTH : positive;
        ADDR_WIDTH : positive);
    port (
        clk, nrst : in std_logic;
        write_en  : in std_logic;

        w_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        r_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        w_data : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        r_data : out std_logic_vector(DATA_WIDTH - 1 downto 0));
end entity;

architecture behavioral of SinglePortRam is
    type RamType is array(0 to 2 ** ADDR_WIDTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal ram : RamType;

    -- required to infer block ram, see Xilinx UG901 P.177
    attribute ram_style               : string;
    attribute ram_style of behavioral : architecture is "block";
begin
    process (clk) begin
        if rising_edge(clk) then
            if write_en = '1' then
                ram(to_integer(unsigned(w_addr))) <= w_data;
            else
                if nrst = '0' then
                    r_data <= (others => '0');
                else
                    r_data <= ram(to_integer(unsigned(r_addr)));
                end if;
            end if;
        end if;
    end process;
end architecture;