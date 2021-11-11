
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

entity control_unit_tb is
end;

architecture a_control_unit_tb of control_unit_tb is
    component control_unit is
        generic (
            block_size: positive;
            block_count: positive;
            rom_content: unsigned_array_t(0 to block_count - 1)(block_size - 1 downto 0)
        );
        port (
            reset: in std_logic;
            clock: in std_logic;
            output: out unsigned(block_size - 1 downto 0);
            opcode_exception: out std_logic
        );
    end component;
    
    constant period_time: time := 100 ns;
    signal finished: std_logic := '0';

    signal clock: std_logic;
    signal reset: std_logic;
    signal write_enable: std_logic;
    signal output: unsigned(15 downto 0);
    signal opcode_exception: std_logic;
    
begin
    control_unit0 : control_unit
    generic map(block_size => 16, block_count => 128, rom_content => (
        0 => "0000000000000000",    --      nop
        1 => "0000000000000000",    --      nop
        2 => "0000000000000000",    --      nop
        3 => "0000000000000000",    --      nop
        4 => "0000000000000000",    --      nop
        5 => "1111000000000111",    --      jump 7
        6 => "0000000000000000",    --      nop
        7 => "0000000000000000",    --      nop
        8 => "1111000000000000",    --      jump 0
        9 => "0000000000000000",    --      nop
        10 => "0100000000000000",   --      nop
        -- abaixo: casos omissos => (zero em todos os bits)
        others => (others => '0')
    ))
    port map(reset => reset, clock => clock, output => output, opcode_exception => opcode_exception);
    
    global_reset: process
    begin
        reset <= '1';
        wait for period_time * 2;
        reset <= '0';
        
        -- teste do reset depois de operações
        wait for 1 us;
        reset <= '1';
        wait for period_time * 2;
        reset <= '0';
        wait;
    end process;
    
    sim_time_proc: process
    begin
        wait for 10 us;
        finished <= '1';
        wait;
    end process sim_time_proc;
    
    clock_proc: process
    begin
        while finished /= '1' loop
            clock <= '0';
            wait for period_time / 2;
            clock <= '1';
            wait for period_time / 2;
        end loop;
        wait;
    end process clock_proc;
    
    process
    begin
        wait for 2000 ns;
        wait;
    end process;
end architecture;