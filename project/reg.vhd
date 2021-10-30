
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is
    generic (
        size: positive
    );
    port (
        clock: in std_logic;
        reset: in std_logic;
        write_enable: in std_logic;
        input: in unsigned(size - 1 downto 0);
        output: out unsigned(size - 1 downto 0)
    );
end entity;

architecture a_reg of reg is
    signal content: unsigned(size - 1 downto 0);
begin
    process(clock, reset)
    begin
        if reset = '1' then
            content <= to_unsigned(0, size);
        elsif write_enable = '1' then
            if rising_edge(clock) then
                content <= input;
            end if;
        end if;
    end process;
    
    output <= content;
end architecture a_reg;
