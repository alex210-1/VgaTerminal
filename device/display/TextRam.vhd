--! TextRam.vhd
--! Implements a dualport ram
--! Alexander Horstkötter 08.11.2022
--! https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/Simple-Dual-Port-Block-RAM-with-Single-Clock-VHDL
--! https://osvvm.org/archives/1758

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TextRam is
    generic (
        SIZE : positive := 20 * 40);
    port (
        nrst       : in std_logic;
        write_clk  : in std_logic;
        write_en   : in std_logic;
        write_addr : in integer range 0 to SIZE - 1;
        write_data : in std_logic_vector(7 downto 0);
        read_clk   : in std_logic;
        read_addr  : in integer range 0 to SIZE - 1;
        read_data  : out std_logic_vector(7 downto 0));
end entity;

architecture behavioral of TextRam is
    type RamArr is array(0 to SIZE - 1) of std_logic_vector(7 downto 0);
    --! this is required to infer dual port ram
    --! it is technically illegal but the alternatives are unsupported, wtf
    shared variable ram : RamArr;

    -- required to infer block ram, see Xilinx UG901 P.177
    attribute ram_style               : string;
    attribute ram_style of behavioral : architecture is "block";
begin
    read_proc : process (read_clk) begin
        if rising_edge(read_clk) then
            if nrst = '0' then
                read_data <= "00000000";
            else
                read_data <= ram(read_addr);
            end if;
        end if;
    end process;

    write_proc : process (write_clk) begin
        if rising_edge(write_clk) then
            if write_en = '1' then
                ram(write_addr) := write_data;
            end if;
        end if;
    end process;
end architecture;