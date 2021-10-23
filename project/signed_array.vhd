
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package signed_array is
    type signed_array_t is array(natural range <>) of signed;
end package signed_array;
