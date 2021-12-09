
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package utils is
    type unsigned_array_t is array(natural range <>) of unsigned;
    
    function bit_count(n: integer) return positive;
    
    function to_unsigned(l: std_logic) return unsigned;
end package utils;

package body utils is
    function bit_count(n: integer) return positive is
    begin
        return integer(ceil(log2(real(n))));
    end function;
    
    function to_unsigned(l: std_logic) return unsigned is
        variable resp: unsigned(0 downto 0);
    begin
        resp(0) := l;
        return resp;
    end function;
    
end package body;
