--! DistanceCore.vhd
--! Alexander Horstkötter 16.01.2023
--! 
--! contains a dedicated memory of cell positions that is written to LUT from outside
--! for fast accces. x and y are concatenated in data and address
--!
--! performs this operation real fast: 
--!     vec2 distv = neighbor + point - f_st;
--!     float dist = dot(distv, distv);

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DistanceCore is
    generic (
        X_OFFSET : integer range -1 to 1 := 0;
        Y_OFFSET : integer range -1 to 1 := 0);
    port (
        clk, nrst : in std_logic;

        write_en           : in std_logic; --! when high w_pos is written to w_addr each tick
        w_addr_x, w_addr_y : in unsigned(2 downto 0);
        w_pos_x, w_pos_y   : in unsigned(6 downto 0);

        int_pos_x, int_pos_y   : in unsigned(2 downto 0);
        frac_pos_x, frac_pos_y : in unsigned(6 downto 0);

        square_dist : out unsigned(10 downto 0)); -- fixed point 3.8, 6 ticks delay
end entity;

architecture behavioral of DistanceCore is
    component SinglePortRam is
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
    end component;

    component DspMultiply is
        generic (
            WIDTH_A : positive;
            WIDTH_B : positive);
        port (
            clk : in std_logic;

            in_a : in signed(WIDTH_A - 1 downto 0);
            in_b : in signed(WIDTH_B - 1 downto 0);

            result : out signed(WIDTH_A + WIDTH_B - 1 downto 0)); --! 3 ticks delay
    end component;

    signal w_addr, r_addr     : std_logic_vector(5 downto 0);
    signal w_data, r_data     : std_logic_vector(13 downto 0);
    signal diff_x, diff_y     : signed(8 downto 0);  -- fixed point 2.7
    signal square_x, square_y : signed(17 downto 0); -- fixed point 4.14
begin
    posBuffer : SinglePortRam
    generic map(
        DATA_WIDTH => 14,
        ADDR_WIDTH => 6)
    port map(
        clk      => clk,
        nrst     => nrst,
        write_en => write_en,
        w_addr   => w_addr,
        w_data   => w_data,
        r_addr   => r_addr,
        r_data   => r_data);

    squareX : DspMultiply
    generic map(
        WIDTH_A => 9,
        WIDTH_B => 9)
    port map(
        clk    => clk,
        in_a   => diff_x,
        in_b   => diff_x,
        result => square_x);

    squareY : DspMultiply
    generic map(
        WIDTH_A => 9,
        WIDTH_B => 9)
    port map(
        clk    => clk,
        in_a   => diff_y,
        in_b   => diff_y,
        result => square_y);

    w_addr <= std_logic_vector(w_addr_x) & std_logic_vector(w_addr_y);
    w_data <= std_logic_vector(w_pos_x) & std_logic_vector(w_pos_y);

    process (clk)
        variable r_addr_x, r_addr_y     : unsigned(2 downto 0);
        variable r_data_x, r_data_y     : std_logic_vector(6 downto 0);
        variable data_off_x, data_off_y : std_logic_vector(8 downto 0); -- fixed point 2.7
        variable square_sum             : unsigned(17 downto 0);        -- fixed point 4.14
    begin
        if rising_edge(clk) then
            if nrst = '0' then
                -- none
            else
                -- === Stage 1 ===
                -- pseudocode:
                -- vec2 neighbor = vec2(float(x),float(y));
                -- vec2 point = rand(i_st + neighbor);
                -- point = 0.5 + 0.5*sin(iTime + 8.0*point); // from ram
                r_addr_x := int_pos_x + to_unsigned(X_OFFSET, 2); -- overflow indended
                r_addr_y := int_pos_Y + to_unsigned(Y_OFFSET, 2);
                r_addr <= std_logic_vector(r_addr_x) & std_logic_vector(r_addr_y);

                -- === Stage 2 ===
                -- pseudocode:
                -- vec2 distv = neighbor + point - f_st;
                r_data_x := r_data(13 downto 7);
                r_data_y := r_data(6 downto 0);

                data_off_x := std_logic_vector(to_unsigned(X_OFFSET, 2)) & r_data_x;
                data_off_y := std_logic_vector(to_unsigned(Y_OFFSET, 2)) & r_data_y;

                diff_x <= signed(data_off_x) - signed("00" & frac_pos_x);
                diff_y <= signed(data_off_x) - signed("00" & frac_pos_y);

                -- Stage 3, 4, 5 in DSP

                -- === Stage 6 ===
                square_sum := unsigned(square_x) + unsigned(square_y);
                -- maximum squared distance is < 8. => 3.8 bits fixed point should suffice
                square_dist <= square_sum(16 downto 5); -- drop MSB
            end if;
        end if;
    end process;
end architecture;