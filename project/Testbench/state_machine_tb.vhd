
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

entity state_machine_tb is
end;

architecture a_state_machine_tb of state_machine_tb is
    component state_machine is
        generic (
            state_count: positive
        );
        port(
            clock: in std_logic;
            reset: in std_logic;
            state: out unsigned((bit_count(state_count) - 1) downto 0)
        );
    end component;
    
    constant period_time: time := 100 ns;
    signal finished: std_logic := '0';

    signal clock: std_logic;
    signal reset: std_logic;
    signal input: std_logic;
    signal output: unsigned(1 downto 0);
    
begin
    
    ff: state_machine
    generic map(state_count => 3)
    port map(clock => clock, reset => reset, state => output);
    
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
        wait for 200 ns;
        
        input <= '1';
        wait for 1000 ns;
        input <= '0';
        wait for 1000 ns;
        wait;
    end process;
end architecture;