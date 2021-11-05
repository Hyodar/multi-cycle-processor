
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

entity decoder is
    generic (
        output_count: positive
    );
    port (
        selector: in unsigned((bit_count(output_count) - 1) downto 0);
        enable: in std_logic;
        outputs: out std_logic_vector(0 to output_count - 1)
    );
end entity decoder;

architecture a_decoder of decoder is
    function is_undef(n: unsigned) return boolean is
    begin
        for i in n'range loop
            case n(i) is
                when 'U' | 'X' | 'Z' | 'W' | '-' => return true;
                when others => return false;
            end case;
        end loop;
        return false;
    end function;
    
    constant ONE: std_logic_vector(0 to output_count - 1) := (0 => '1', others => '0');
    constant UNDEF: std_logic_vector(0 to output_count - 1) := (others => 'U');
begin
    outputs <= UNDEF when ((enable = '0') or is_undef(selector)) else ONE srl to_integer(selector);
end architecture a_decoder;
