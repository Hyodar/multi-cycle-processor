
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.state.all;

entity state_machine is
    port(
        clock: in std_logic;
        reset: in std_logic;
        state: out state_t
    );
end entity state_machine;

architecture a_state_machine of state_machine is
    signal state_s: state_t;
begin
    process(clock, reset)
    begin
        if reset = '1' then
            state_s <= ST_FETCH;
        elsif rising_edge(clock) then
            if state_s = ST_EXECUTE then
                state_s <= ST_FETCH;
            else
                state_s <= state_s + 1;
            end if;
        end if;
    end process;
    state <= state_s;
end architecture a_state_machine;
