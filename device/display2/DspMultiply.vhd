--! DspAddMult.vhd
--! Alexander Horstkötter 16.01.2023
--! https://docs.xilinx.com/v/u/en-US/ug479_7Series_DSP48E1
--!
--! Instantiates a single DSP48E1 without pre and post adders
--! computation is pipelined with 3 ticks delay

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DspMultiply is
    generic (
        WIDTH_A : positive;
        WIDTH_B : positive);
    port (
        clk : in std_logic;

        in_a : in signed(WIDTH_A - 1 downto 0);
        in_b : in signed(WIDTH_B - 1 downto 0);

        result : out signed(WIDTH_A + WIDTH_B - 1 downto 0)); --! 3 ticks delay
end entity;

architecture behavioral of DspMultiply is
    signal reg_a : signed(WIDTH_A - 1 downto 0);
    signal reg_b : signed(WIDTH_B - 1 downto 0);

    -- delay result signal to match speed of DSP
    signal pipe_0 : signed(WIDTH_A + WIDTH_B - 1 downto 0);

    attribute use_dsp               : string;
    attribute use_dsp of behavioral : architecture is "yes";
begin
    process (clk) begin
        if rising_edge(clk) then
            -- I don't think a reset makes sense here?

            reg_a <= in_a;
            reg_b <= in_b;

            pipe_0 <= reg_a * reg_b;
            result <= pipe_0;
        end if;
    end process;
end architecture;