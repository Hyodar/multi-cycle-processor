
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

entity rom is
    generic (
        block_size: positive;
        block_count: positive;
        rom_content: unsigned_array_t(0 to block_count - 1)(block_size - 1 downto 0)
    );
    port (
        clock: in std_logic;
        address: in unsigned((bit_count(block_count) - 1) downto 0);
        enable: in std_logic;
        output: out unsigned(block_size - 1 downto 0)
    );
end entity;

architecture a_rom of rom is
begin
    -- process(clock)
    -- begin
    --     if enable = '1' then
    --         if (rising_edge(clock)) then
                output <= rom_content(to_integer(address));
    --         end if;
    --     end if;
    -- end process;
end architecture a_rom;
