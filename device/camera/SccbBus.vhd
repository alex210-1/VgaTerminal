--! SccbBus.vhd  
--! Alexander Horstkötter 23.12.2022  
--!
--! Implements the Omnivision Serial Camera Control Bus (2-Wire mode) (similar to I2C) 
--! 
--! The crappy spec: https://github.com/rggber/rggber-documentations/blob/master/OV5640/Omnivision%20serial%20camera%20control%20bus(SCCB)%20functional%20specification.pdf 
--! Helpful: https://thecodeartist.blogspot.com/2012/04/omnivison-ov3640-i2c-sccb.html  
--!
--! ### Notable differences to I2C:  
--! - According to the spec ACKs are not guaranteed from the slave and the master should ignore them,
--!   during this 9th bit the master is supposed to output hi-z
--! - Push-pull drivers are used instead of open-drain. A short-protection resistor on the sio-d line
--!   is required instead of pullup resistors. The value of that resistor is not specified  
--! - The structure of message transfers is limited to an addressed read and an addressed write  
--! - The master needs to drive 9th bit of response phase high as ack  
--! - I am unsure what happens between read and response phases
--!
--! ### Diagrams
--! {signal: [
--!   {name: 'clk ->', 			wave: 'n..|.|..|..'},
--!   {name: 'bus_ready <-', 	wave: '1.0|1|.0|.1'},
--!   {name: 'send_valid ->', 	wave: '01x|0|1x|.0'},
--!   {name: 'read_flag ->', 	wave: 'x0x|.|1x|.x'},
--!   {name: 'read_valid <-', 	wave: '0..|.|..|10'},
--!   {name: 'addr ->', 		wave: 'x2x|.|2x|..'},
--!   {name: 'sub_addr ->', 	wave: 'x2x|.|2x|..'},
--!   {name: 'write_data ->', 	wave: 'x2x|.|.x|..'},
--!   {name: 'read_data <-', 	wave: 'x..|.|.x|2x'},
--!   {name: 'state',			wave: '02...02...0', data: ['write', 'read']}
--! ], 
--!   head: {text: 'SCCB write and read cycle. Application layer'}
--! }
--!
--! {signal : [
--!   ["Write",
--!     {name : 'sio - c', wave : 'h|..n.................h|'},
--!     {name : 'sio - d', wave : '1|.022.20z33..3z44..4z1|', data : ['b7', 'Address', 'b1', 'b7', 'SubAddr', 'b0', 'b7', 'Data', 'b0']}
--!   ],
--!   {},
--!   ["Read",
--!     {name : 'sio - c', wave : 'h|..n...........|'},
--!     {name : 'sio - d', wave : '1|.022.21z33..3z|', data : ['b7', 'Address', 'b1', 'b7', 'SubAddr', 'b0']}
--!   ],
--!   {},
--!   ["Response",
--!     {name : 'sio - c', wave : 'n|............h|'},
--!     {name : 'sio - d', wave : 'z|44..4z55..5.1|', data : ['b7', 'Address', 'b0', 'b7', 'Data', 'b0']}
--!   ]
--! ],
--!   head: {text: 'SCCB write and read cycle. Physical layer'}
--! }
--!
--! ### Changelog
--! - 30.12.2022: Successfully simulated and synthesized

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SccbBus is
    port (
        clk, nrst  : in std_logic;
        bus_ready  : out std_logic; --! high when able to receive data. handshakes with send_valid
        send_valid : in std_logic;  --! master has data to be transmitted (either read or write)
        read_flag  : in std_logic;  --! when high a read operation is performed, else write
        read_valid : out std_logic; --! data is valid until next transmittion start

        addr       : in std_logic_vector(6 downto 0);  --! slave address
        sub_addr   : in std_logic_vector(7 downto 0);  --! register address
        write_data : in std_logic_vector(7 downto 0);  --! data to be writen to sub_addr
        read_data  : out std_logic_vector(7 downto 0); --! data read from sub_addr

        sio_c : out std_logic;    --! SCCB clock signal (100kHz max)
        sio_d : inout std_logic); --! SCCB data signal (tristate) 
end entity;

architecture behavioral of SccbBus is
    constant CLK_DIV : integer := 1000; --! divide from 100MHz to 100kHz

    type state_type is (
        READY,
        START,
        W_ADDR,
        W_SUBADDR,
        W_DATA,
        R_ADDR,
        R_DATA,
        STOP
    );

    signal state : state_type;
    --! what bis is currently being written/read in the current phase? 0 -> MSB, 7 -> LSB, 8 -> DC
    signal current_bit : integer range 0 to 8;
    signal clk_count   : integer range 0 to CLK_DIV - 1; --! counter is started on handshake
    signal sccb_clock  : std_logic;                      --! 100kHz clock

    signal clk_falling : std_logic;
    signal clk_rising  : std_logic;

    signal read_flag_buffer : std_logic; --! stores the read_flag to simplify the state machine
    signal addr_buffer      : std_logic_vector(7 downto 0);
    signal sub_addr_buffer  : std_logic_vector(7 downto 0);
    signal data_buffer      : std_logic_vector(7 downto 0);
begin
    bus_ready <= '1' when state = READY else '0';

    --! using single-process fsm because it seems to simplifty the logic
    --! fsm_extract
    fsm : process (clk) begin
        if rising_edge(clk) then
            if nrst = '0' then
                state      <= READY;
                read_valid <= '0';
            else
                case state is
                    when READY =>
                        if send_valid = '1' then
                            state <= START;
                            -- store input data
                            read_flag_buffer        <= read_flag;
                            addr_buffer(7 downto 1) <= addr;
                            addr_buffer(0)          <= read_flag;
                            sub_addr_buffer         <= sub_addr;
                            data_buffer             <= write_data;
                            read_valid              <= '0';
                        end if;
                    when START =>
                        if clk_falling = '1' then
                            state <= W_ADDR;
                        end if;
                    when W_ADDR =>
                        if clk_falling = '1' then
                            if current_bit = 8 then
                                state       <= W_SUBADDR;
                                current_bit <= 0;
                            else
                                -- shift out address (MSB first)
                                addr_buffer <= addr_buffer(6 downto 0) & '0';
                                current_bit <= current_bit + 1;
                            end if;
                        end if;
                    when W_SUBADDR =>
                        if clk_falling = '1' then
                            if current_bit = 8 then
                                if read_flag = '1' then
                                    state <= R_ADDR;
                                else
                                    state <= W_DATA;
                                end if;

                                current_bit <= 0;
                            else
                                -- shift out subaddress (MSB first)
                                sub_addr_buffer <= sub_addr_buffer(6 downto 0) & '0';
                                current_bit     <= current_bit + 1;
                            end if;
                        end if;
                    when W_DATA =>
                        if clk_falling = '1' then
                            if current_bit = 8 then
                                state       <= STOP;
                                current_bit <= 0;
                            else
                                -- shift out data (MSB first)
                                data_buffer <= data_buffer(6 downto 0) & '0';
                                current_bit <= current_bit + 1;
                            end if;
                        end if;
                    when R_ADDR =>
                        if clk_falling = '1' then
                            if current_bit = 8 then
                                state       <= R_DATA;
                                current_bit <= 0;
                            else
                                -- read address is currently ignored
                                current_bit <= current_bit + 1;
                            end if;
                        end if;
                    when R_DATA =>
                        if clk_falling = '1' then
                            if current_bit = 8 then
                                state       <= STOP;
                                current_bit <= 0;
                                read_valid  <= '1';
                                read_data   <= data_buffer;
                            else
                                current_bit <= current_bit + 1;
                            end if;
                        elsif clk_rising = '1' and current_bit /= 8 then
                            -- TODO not sure if this works
                            -- sample bus data on rising edge (MSB first)
                            data_buffer <= data_buffer(6 downto 0) & sio_d;
                        end if;
                    when STOP =>
                        if clk_falling = '1' then
                            state <= READY;
                        end if;
                end case;
            end if;
        end if;
    end process;

    -- this is sequential to avoid output hazards and for correct timing
    output : process (clk) begin
        if rising_edge(clk) then
            if nrst = '0' then
                sccb_clock <= '0';

                sio_c <= '1';
                sio_d <= '1';
            else
                sccb_clock <= '0' when clk_count < CLK_DIV / 2 else '1';

                sio_c <= sccb_clock;

                case state is
                    when READY =>
                        sio_c <= '1';
                        sio_d <= '1';
                    when START =>
                        sio_c <= '1';
                        sio_d <= '0';
                    when W_ADDR =>
                        sio_d <= 'Z' when current_bit = 8 else addr_buffer(7);
                    when W_SUBADDR =>
                        sio_d <= 'Z' when current_bit = 8 else sub_addr_buffer(7);
                    when W_DATA =>
                        sio_d <= 'Z' when current_bit = 8 else data_buffer(7);
                    when R_ADDR =>
                        sio_d <= 'Z';
                    when R_DATA =>
                        sio_d <= '1' when current_bit = 8 else 'Z';
                    when STOP =>
                        sio_c <= '1';
                        sio_d <= '1'; -- TODO not sure whether this is valid
                end case;
            end if;
        end if;
    end process;

    --! generate 100kHz clock
    clk_gen : process (clk) begin
        if rising_edge(clk) then
            -- counter is started when bus_ready goes low to synchronize the clock
            if nrst = '0' then
                clk_count   <= 0;
                clk_falling <= '0';
                clk_rising  <= '0';
            else
                if bus_ready = '1' or clk_count = CLK_DIV - 1 then
                    clk_count <= 0;
                else
                    clk_count <= clk_count + 1;
                end if;

                clk_falling <= '1' when clk_count = CLK_DIV - 1 else '0';
                clk_rising  <= '1' when clk_count = CLK_DIV / 2 - 1 else '0';
            end if;
        end if;
    end process;
end architecture;