
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package instruction is
    subtype instruction_t is unsigned(15 downto 0);
    subtype instr_section_t is unsigned(3 downto 0);
    subtype opcode_t is instr_section_t;
    
    constant OP_NOP: opcode_t := "0000";
    constant OP_ADD: opcode_t := "0001";
    constant OP_SUB: opcode_t := "0010";
    constant OP_SUBI: opcode_t := "0011";
    constant OP_MOV: opcode_t := "0100";
    constant OP_LDI: opcode_t := "0101";
    constant OP_JMP: opcode_t := "1111";

    subtype progmem_address_t is unsigned(15 downto 0);
    constant ROM_SIZE: integer := 65536; -- 2^16

    subtype reg_content_t is unsigned(7 downto 0);
    subtype reg_address_t is unsigned(3 downto 0);
    constant REG_COUNT: integer := 16; -- 2^4

    subtype alu_operand_t is unsigned(15 downto 0);

end package instruction;
