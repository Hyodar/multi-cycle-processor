
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
        pc_source: out unsigned(1 downto 0);
        value_write: out unsigned(1 downto 0);
        alu_op: out unsigned(1 downto 0);
        alu_src_a: out unsigned(0 downto 0);
        alu_src_b: out unsigned(1 downto 0);
        mem_read: out std_logic
    );
end entity control_unit;

architecture a_control_unit of control_unit is
begin
    ir_write <= '1' when state = ST_FETCH else '0';
    pc_write <= '1' when state = ST_FETCH or (operation = OP_JMP and state = ST_EXECUTE) else '0';
    reg_write <= '1' when state = ST_EXECUTE and operation /= OP_NOP and operation /= OP_JMP else '0';
    value_write <=  "10" when (operation = OP_MOV and state = ST_EXECUTE) else
        "01" when (operation /= OP_LDI and state = ST_EXECUTE)
        else "00";
    pc_source <= "10" when (operation = OP_JMP and state = ST_EXECUTE) else "00";
    alu_op <= "00" when state = ST_FETCH or (operation = OP_ADD and state = ST_EXECUTE) else "01";
    alu_src_a <= "0" when (state = ST_FETCH or state = ST_DECODE) else "1";
    alu_src_b <= "01" when state = ST_FETCH else
        "10" when (state = ST_EXECUTE and operation = OP_SUBI) else
        "00";
    status_write <= '1' when state = ST_EXECUTE else '0';
    mem_read <= '1' when state = ST_FETCH else '0';
    
end architecture a_control_unit;
