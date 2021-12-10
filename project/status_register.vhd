
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.instruction.all;
use work.status.all;
use work.utils.all;

entity status_register is
    port (
        clock: in std_logic;
        reset: in std_logic;
        write_enable: in status_t;
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
    signal imm: reg_content_t;
    signal status: status_t;
    signal is_zero: std_logic;
    
    signal out_carry: unsigned(0 downto 0);
    signal out_zero: unsigned(0 downto 0);
    signal out_negative: unsigned(0 downto 0);
    signal out_overflow: unsigned(0 downto 0);
    signal out_sign: unsigned(0 downto 0);
    signal out_half_carry: unsigned(0 downto 0);
    signal out_bit_copy: unsigned(0 downto 0);
    signal out_interrupt: unsigned(0 downto 0);

    constant LAST_BIT: integer := reg_content_t'length - 1;
    constant MIDDLE_BIT: integer := (reg_content_t'length - 1) / 2;
    
    alias l: integer is LAST_BIT;
    alias m: integer is MIDDLE_BIT;

begin
    reg_carry: reg
    generic map(size => 1)
    port map(clock => clock, reset => reset, write_enable => write_enable.carry, input => to_unsigned(status.carry), output => out_carry);
    reg_zero: reg
    generic map(size => 1)
    port map(clock => clock, reset => reset, write_enable => write_enable.zero, input => to_unsigned(status.zero), output => out_zero);
    reg_negative: reg
    generic map(size => 1)
    port map(clock => clock, reset => reset, write_enable => write_enable.negative, input => to_unsigned(status.negative), output => out_negative);
    reg_overflow: reg
    generic map(size => 1)
    port map(clock => clock, reset => reset, write_enable => write_enable.overflow, input => to_unsigned(status.overflow), output => out_overflow);
    reg_sign: reg
    generic map(size => 1)
    port map(clock => clock, reset => reset, write_enable => write_enable.sign, input => to_unsigned(status.sign), output => out_sign);
    reg_half_carry: reg
    generic map(size => 1)
    port map(clock => clock, reset => reset, write_enable => write_enable.half_carry, input => to_unsigned(status.half_carry), output => out_half_carry);
    reg_bit_copy: reg
    generic map(size => 1)
    port map(clock => clock, reset => reset, write_enable => write_enable.bit_copy, input => to_unsigned(status.bit_copy), output => out_bit_copy);
    reg_interrupt: reg
    generic map(size => 1)
    port map(clock => clock, reset => reset, write_enable => write_enable.interrupt, input => to_unsigned(status.interrupt), output => out_interrupt);

    imm <= resize(section2 & section3, reg_content_t'length);
    output <= unsigned_to_status(out_carry & out_zero & out_negative & out_overflow & out_sign & out_half_carry & out_bit_copy & out_interrupt);

    status.carry <= (arg0(l) and arg1(l)) or (arg1(l) and not result(l)) or (not result(l) and arg0(l)) when operation = OP_ADD else
    (not arg0(l) and arg1(l)) or (arg1(l) and result(l)) or (result(l) and not arg0(l)) when (operation = OP_SUB or operation = OP_CP) else
    (not arg0(l) and imm(l)) or (imm(l) and result(l)) or (result(l) and not arg0(l))   when (operation = OP_SUBI or operation = OP_CPI) else
    '0';

    is_zero <= '1' when result = to_unsigned(0, reg_content_t'length) else '0';
    
    status.zero <= is_zero when (operation = OP_ADD or operation = OP_SUB or operation = OP_CP or operation = OP_SUBI or operation = OP_CPI) else
    '0';
    
    status.negative <= result(l) when (operation = OP_ADD or operation = OP_SUB or operation = OP_CP or operation = OP_SUBI or operation = OP_CPI) else
    '0';
    
    status.overflow <= (arg0(l) and arg1(l) and not result(l)) or (not arg0(l) and not arg1(l) and result(l)) when operation = OP_ADD  else
    (arg0(l) and not arg1(l) and not result(l)) or (not arg0(l) and arg1(l) and result(l)) when (operation = OP_SUB or operation = OP_CP)  else
    (arg0(l) and not imm(l) and not result(l)) or (not arg0(l) and imm(l) and result(l))   when (operation = OP_SUBI or operation = OP_CPI) else
    '0';
    
    status.sign <= (status.overflow xor status.negative) when (operation = OP_ADD or operation = OP_SUB or operation = OP_CP or operation = OP_SUBI or operation = OP_CPI) else
    '0';

    status.half_carry <= (arg0(m) and arg1(m)) or (arg1(m) and not result(m)) or (not result(m) and arg0(m)) when operation = OP_ADD  else
    (not arg0(m) and arg1(m)) or (arg1(m) and result(m)) or (result(m) and not arg0(m)) when (operation = OP_SUB or operation = OP_CP)  else
    (not arg0(m) and imm(m)) or (imm(m) and result(m)) or (result(m) and not arg0(m))   when (operation = OP_SUBI or operation = OP_CPI) else
    '0';
    
    status.bit_copy <= '1' when status.bit_copy = '1' else '0';
    
    status.interrupt <= '1' when status.interrupt = '1' else '0';

end architecture a_status_register;
