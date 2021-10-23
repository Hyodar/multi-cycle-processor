
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.unsigned_array.all;

entity rom is
    generic (
        block_size: positive;
        block_count: positive;
        rom_content: unsigned_array_t(0 to block_count - 1)(block_size - 1 downto 0)
    );
    port (
        clock: in std_logic;
        address: in unsigned((integer(ceil(log2(real(block_count)))) - 1) downto 0);
        output: out unsigned(block_size - 1 downto 0)
    );
end entity;

architecture a_rom of rom is
begin
    process(clock)
    begin
        if (rising_edge(clock)) then
            output <= rom_content(to_integer(address));
        end if;
    end process;
end architecture a_rom;
