
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

entity state_machine is
    generic (
        state_count: positive
    );
    port(
        clock: in std_logic;
        reset: in std_logic;
        state: out unsigned((bit_count(state_count) - 1) downto 0)
    );
end entity state_machine;

architecture a_state_machine of state_machine is
    signal state_s: state'subtype;
begin
    process(clock, reset)
    begin
        if reset = '1' then
            state_s <= to_unsigned(0, bit_count(state_count));
        elsif rising_edge(clock) then
            if state_s = to_unsigned(state_count - 1, bit_count(state_count)) then
                state_s <= to_unsigned(0, bit_count(state_count));
            else
                state_s <= state_s + 1;
            end if;
        end if;
    end process;
    state <= state_s;
end architecture a_state_machine;