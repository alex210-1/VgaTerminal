--! MclkGen.vhd
--! Alexander Horstkötter 02.12.2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MclkGenPll is
    port (
        nrst                  : in std_logic;
        clk_440mhz, lrclk_ref : in std_logic;
        m_clk                 : out std_logic);
end entity;

architecture behavioral of MclkGenPll is
    signal mclk_count       : integer range 0 to 19;
    signal lrclk_count      : unsigned(7 downto 0);
    signal lrclk_synth      : std_logic;
    signal lrclk_synth_last : std_logic;
    signal lrclk_ref_buf    : std_logic;
    signal go_faster        : std_logic;
begin
    lrclk_synth <= lrclk_count(7);

    process (clk_440mhz) begin
        if rising_edge(clk_440mhz) then
            if nrst = '0' then
                mclk_count       <= 0;
                lrclk_count      <= (others => '0');
                lrclk_synth_last <= '0';
                go_faster        <= '0';
                m_clk            <= '0';
            else
                lrclk_synth_last <= lrclk_synth;
                lrclk_ref_buf    <= lrclk_ref;

                -- first divider
                if mclk_count = 0 then
                    mclk_count <= 18 when go_faster = '1' else 19;
                    m_clk      <= not m_clk;

                    if m_clk = '0' then
                        lrclk_count <= lrclk_count + 1;
                    end if;
                else
                    mclk_count <= mclk_count - 1;
                end if;

                -- phase detector
                if lrclk_synth = '1' and lrclk_synth_last = '0' then
                    go_faster <= lrclk_ref_buf;
                end if;
            end if;
        end if;
    end process;
end architecture;