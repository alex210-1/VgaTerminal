-- https://www.mikrocontroller.net/attachment/345739/vhdl2proc.pdf

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package NiceCounter_comp is
    type NiceCounter_intype is record
        load, count: std_logic;
        din: unsigned(7 downto 0);
    end record;
    
    type NiceCounter_outtype is record
        dout: unsigned(7 downto 0);
        zero: std_logic;
    end record;
    
    component NiceCounter
        port (
            clk: in std_logic;
            d: in NiceCounter_intype;
            q: in NiceCounter_outtype);
    end component;
end package;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.NiceCounter_comp.all;

entity NiceCounter is
    port (
        clk: in std_logic;
        d: in NiceCounter_intype;
        q: in NiceCounter_outtype);
end NiceCounter;

architecture twoproc of NiceCounter is
    type reg_type is record
        load, count, zero: std_logic;
        cval: unsigned(7 downto 0);
    end record;
    signal r, rin: reg_type;
begin
    comb: process(d, r)
        variable v: reg_type;
    begin
        v := r; -- default assignment
        v.load := d.load;  -- overriding assignments
        v.count := d.count;
        v.zero := '0';
        
        -- actual algorithm here
        if r.count = '1' then 
            v.cval := r.cval + 1; 
        end if;
        if r.load = '1' then
            v.cval := d.din;
        end if;
        if v.cval = "00000000" then
            v.zero := '1';
        end if;
    end process;
    
    regs: process(clk) 
    begin
        if rising_edge(clk) then
            r <= rin;
        end if;
    end process;
end twoproc;
