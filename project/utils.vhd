
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package utils is
    type unsigned_array_t is array(natural range <>) of unsigned;
    
    function bit_count(n: integer) return positive;
end package utils;

package body utils is
    function bit_count(n: integer) return positive is
    begin
        return integer(ceil(log2(real(n))));
    end function;
end package body;
