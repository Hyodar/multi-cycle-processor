
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

entity ram is
    generic (
        block_size: positive;
        block_count: positive
    );
    port (
        clock: in std_logic;
        address: in unsigned((bit_count(block_count) - 1) downto 0);
        write_enable: in std_logic;
        write_data: in unsigned(block_size - 1 downto 0);
        output: out unsigned(block_size - 1 downto 0)
    );
end entity;

architecture a_ram of ram is
    
    signal content: unsigned_array_t(0 to block_count - 1)(block_size - 1 downto 0);
begin
    process(clock,write_enable)
    begin
        if rising_edge(clock) then
            if write_enable='1' then
                content(to_integer(address)) <= write_data;
            end if;
        end if;
    end process;
    output <= content(to_integer(address));
end architecture a_ram;