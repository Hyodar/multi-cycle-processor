
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package state is
    constant STATE_SIZE: integer := 2;
    subtype state_t is unsigned(STATE_SIZE - 1 downto 0);
    
    constant ST_FETCH: state_t := "00";
    constant ST_DECODE: state_t := "01";
    constant ST_EXECUTE: state_t := "10";
end package state;
