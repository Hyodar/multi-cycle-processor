
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package opcodes is
    constant OPCODE_SIZE: integer := 4;
    constant OP_JUMP: unsigned(OPCODE_SIZE - 1 downto 0) := "1111";
    constant OP_NOP: unsigned(OPCODE_SIZE - 1 downto 0) := "0000";
end package opcodes;
