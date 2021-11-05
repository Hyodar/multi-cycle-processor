
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

entity mux is
    generic (
        input_count: positive;
        bus_width: positive
    );
    port (
        inputs: in unsigned_array_t(0 to (input_count - 1))((bus_width - 1) downto 0);
        selector: in unsigned((bit_count(input_count) - 1) downto 0);
        output: out unsigned((bus_width - 1) downto 0)
    );
end entity;

architecture a_mux of mux is
begin
    output <= inputs(to_integer(selector));
end architecture a_mux;
