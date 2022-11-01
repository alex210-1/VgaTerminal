-- StreamBuffer.vhd
-- Interface definition for a basic AXI4-stream
--
-- Alexander Horstkötter 30.10.2022

library IEEE;
use IEEE.std_logic_1164.all;

package BasicStream is
    type BasicStreamMaster_intype is record
        load, count: std_logic;
        din: std_logic_vector(7 downto 0);
    end record;
    
    type BasicStreamMaster_outtype is record
        dout: std_logic_vector(7 downto 0);
        zero: std_logic;
    end record;

end package;
