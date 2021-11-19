
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.instruction.all;
use work.status.all;

entity status_register is
    port (
        clock: in std_logic;
        reset: in std_logic;
        write_enable: in std_logic;
        operation: in opcode_t;
        section1: in instr_section_t;
        section2: in instr_section_t;
        section3: in instr_section_t;
        arg0: in reg_content_t;
        arg1: in reg_content_t;
        result: in reg_content_t;
        output: out status_t
    );
end entity;

architecture a_status_register of status_register is
component reg is
    generic (
        size: positive
    );
    port (
        clock: in std_logic;
        reset: in std_logic;
        write_enable: in std_logic;
        input: in unsigned(size - 1 downto 0);
        output: out unsigned(size - 1 downto 0)
    );
end component reg;
    signal reg0_input: unsigned(7 downto 0);
    signal reg0_output: unsigned(7 downto 0);
    signal imm: reg_content_t;
    signal status: status_t;
    signal is_zero: std_logic;

    constant LAST_BIT: integer := reg_content_t'length - 1;
    constant MIDDLE_BIT: integer := (reg_content_t'length - 1) / 2;
    
    alias l: integer is LAST_BIT;
    alias m: integer is MIDDLE_BIT;

begin
    reg0: reg
    generic map(size => 8)
    port map(clock => clock, reset => reset, write_enable => write_enable, input => reg0_input, output => reg0_output);

    imm <= resize(section2 & section3, reg_content_t'length);
    output <= unsigned_to_status(reg0_output);

    status.carry <= (arg0(l) and arg1(l)) or (arg1(l) and not result(l)) or (not result(l) and arg0(l)) when operation = OP_ADD else
                    (not arg0(l) and arg1(l)) or (arg1(l) and result(l)) or (result(l) and not arg0(l)) when (operation = OP_SUB or operation = OP_CP) else
                    (not arg0(l) and imm(l)) or (imm(l) and result(l)) or (result(l) and not arg0(l))   when (operation = OP_SUBI or operation = OP_CPI) else
                    '1' when (status.carry = '1') else '0';

    is_zero <= '1' when result = to_unsigned(0, reg_content_t'length) else '0';
    
    status.zero <= is_zero when (operation = OP_ADD or operation = OP_SUB or operation = OP_CP or operation = OP_SUBI or operation = OP_CPI) else
                   '1' when (status.zero = '1') else '0';
    
    status.negative <= result(l) when (operation = OP_ADD or operation = OP_SUB or operation = OP_CP or operation = OP_SUBI or operation = OP_CPI) else
                       '1' when (status.negative = '1') else '0';
    
    status.overflow <= (arg0(l) and arg1(l) and not result(l)) or (not arg0(l) and not arg1(l) and result(l)) when operation = OP_ADD  else
                       (arg0(l) and not arg1(l) and not result(l)) or (not arg0(l) and arg1(l) and result(l)) when (operation = OP_SUB or operation = OP_CP)  else
                       (arg0(l) and not imm(l) and not result(l)) or (not arg0(l) and imm(l) and result(l))   when (operation = OP_SUBI or operation = OP_CPI) else
                       '1' when (status.overflow = '1') else '0';
    
    status.sign <= (status.overflow xor status.negative) when (operation = OP_ADD or operation = OP_SUB or operation = OP_CP or operation = OP_SUBI or operation = OP_CPI) else
                   '1' when (status.sign = '1') else '0';

    status.half_carry <= (arg0(m) and arg1(m)) or (arg1(m) and not result(m)) or (not result(m) and arg0(m)) when operation = OP_ADD  else
                         (not arg0(m) and arg1(m)) or (arg1(m) and result(m)) or (result(m) and not arg0(m)) when (operation = OP_SUB or operation = OP_CP)  else
                         (not arg0(m) and imm(m)) or (imm(m) and result(m)) or (result(m) and not arg0(m))   when (operation = OP_SUBI or operation = OP_CPI) else
                         '1' when (status.half_carry = '1') else '0';
    
    status.bit_copy <= '1' when status.bit_copy = '1' else '0';
    
    status.interrupt <= '1' when status.interrupt = '1' else '0';

    reg0_input <= status_to_unsigned(status);

end architecture a_status_register;
