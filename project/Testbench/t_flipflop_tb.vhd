
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

entity t_flipflop_tb is
end;

architecture a_t_flipflop_tb of t_flipflop_tb is
    component t_flipflop is
        port (
            clock: in std_logic;
            reset: in std_logic;
            input: in std_logic;
            output: out std_logic
        );
    end component;
    
    constant period_time: time := 100 ns;
    signal finished: std_logic := '0';

    signal clock: std_logic;
    signal reset: std_logic;
    signal input: std_logic;
    signal output: std_logic;
    
begin
    
    ff: t_flipflop
    port map(clock => clock, reset => reset, input => input, output => output);
    
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