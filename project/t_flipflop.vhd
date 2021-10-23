
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity t_flipflop is
    port (
        clock: in std_logic;
        reset: in std_logic;
        input: in std_logic;
        output: out std_logic
    );
end entity;

architecture a_t_flipflop of t_flipflop is
    signal content: std_logic;
begin
    process(clock, reset)
    begin
        if reset = '1' then
            content <= '0';
        elsif rising_edge(clock) then
            content <= (not content) when input = '1' else content;
        end if;
    end process;
    
    output <= content;
end architecture a_t_flipflop;
