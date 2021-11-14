
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
        not_ldi: out unsigned(0 downto 0);
        alu_op: out unsigned(1 downto 0);
        alu_src_a: out unsigned(0 downto 0);
        alu_src_b: out unsigned(1 downto 0)
    );
end entity control_unit;

architecture a_control_unit of control_unit is
begin
    ir_write <= '1' when state = ST_DECODE else '0';
    pc_write <= '1' when state = ST_FETCH or (operation = OP_JMP and state = ST_EXECUTE) else '0';
    
    -- TODO quando tivermos mais operações, vamos ter que mudar esse sinal aqui
    reg_write <= '1' when state = ST_EXECUTE and operation /= OP_NOP and operation /= OP_JMP;
    not_ldi <= "1" when operation /= OP_LDI else "0";
    pc_source <= "01" when operation = OP_JMP else "00"; -- quando tem q ser 11?
    
    -- TODO
    -----------------------------------
    
    alu_op <= "00";
    alu_src_a <= "0" when state = ST_FETCH else "1";
    alu_src_b <= "01" when state = ST_FETCH else "00";
    status_write <= '1';
    
end architecture a_control_unit;
