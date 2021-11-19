
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;
use work.instruction.all;
use work.state.all;
use work.status.all;

entity control_unit is
    port(
        operation: in opcode_t;
        state: in state_t;
        status: in status_t;
        pc_write: out std_logic;
        ir_write: out std_logic;
        reg_write: out std_logic;
        status_write: out std_logic;
        pc_source: out unsigned(0 downto 0);
        value_write: out unsigned(1 downto 0);
        alu_op: out unsigned(1 downto 0);
        alu_src_a: out unsigned(0 downto 0);
        alu_src_b: out unsigned(1 downto 0);
        data_mem_write: out std_logic
    );
end entity control_unit;

architecture a_control_unit of control_unit is

    signal branch_enable: std_logic;

begin

    branch_enable <= '1' when
    (operation = OP_BRLO and status.carry = '1') or
    (operation = OP_BREQ and status.zero = '1') or
    (operation = OP_BRNE and status.zero = '0')
else '0';

    ir_write <= '1' when state = ST_FETCH else '0';
    pc_write <= '1' when state = ST_FETCH or ((operation = OP_JMP or branch_enable = '1') and state = ST_EXECUTE) else '0';
    reg_write <= '1' when state = ST_EXECUTE and (operation = OP_ADD or operation = OP_SUB or operation = OP_SUBI or operation = OP_MOV or operation = OP_LDI or operation = OP_LD) else '0';
    value_write <= "11" when (operation = OP_LD and state = ST_EXECUTE) else
        "10" when (operation = OP_MOV and state = ST_EXECUTE) else
        "01" when (operation /= OP_LDI and state = ST_EXECUTE)
else "00";
    pc_source <= "1" when (operation = OP_JMP and state = ST_EXECUTE) else "0";
    alu_op <= "00" when state = ST_FETCH or ((operation = OP_ADD or operation = OP_BREQ or operation = OP_BRLO or operation = OP_BRNE) and state = ST_EXECUTE) else "01";
    alu_src_a <= "0" when (state = ST_FETCH or state = ST_DECODE or ((operation = OP_BREQ or operation = OP_BRLO or operation = OP_BRNE) and state = ST_EXECUTE)) else "1";
    alu_src_b <= "01" when state = ST_FETCH else
        "10" when (state = ST_EXECUTE and (operation = OP_SUBI or operation = OP_CPI)) else
        "11" when (state = ST_EXECUTE and (operation = OP_BREQ or operation = OP_BRLO or operation = OP_BRNE)) else
        "00";
    status_write <= '1' when state = ST_EXECUTE else '0';
    data_mem_write <= '1' when (operation = OP_ST and state = ST_EXECUTE) else '0';

end architecture a_control_unit;
