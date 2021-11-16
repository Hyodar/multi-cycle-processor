
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils.all;
use work.instruction.all;
use work.state.all;
use work.status.all;

entity processador is
    generic(
        rom_content: unsigned_array_t(0 to ROM_SIZE - 1)(instruction_t'length - 1 downto 0)
    );
    port(
        clock: in std_logic;
        reset: in std_logic;
        TOPLVL_state: out state_t;
        TOPLVL_pc: out progmem_address_t;
        TOPLVL_instruction: out instruction_t;
        TOPLVL_reg1: out reg_content_t;
        TOPLVL_reg2: out reg_content_t;
        TOPLVL_alu: out alu_operand_t
    );
end entity;

architecture a_processador of processador is

-- Components
-- ---------------------------------------------------------------------------
component regbank is
    generic (
        reg_count: positive;
        reg_size: positive
    );
    port(
        read_register1: in unsigned((bit_count(reg_count) - 1) downto 0);
        read_register2: in unsigned((bit_count(reg_count) - 1) downto 0);
        write_register: in unsigned((bit_count(reg_count) - 1) downto 0);
        write_data: in unsigned(reg_size - 1 downto 0);
        write_enable: in std_logic;
        clock: in std_logic;
        reset: in std_logic;
        read_data1: out unsigned(reg_size - 1 downto 0);
        read_data2: out unsigned(reg_size - 1 downto 0)
    );
end component regbank;
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
component instruction_register is
    port (
        clock: in std_logic;
        reset: in std_logic;
        write_enable: in std_logic;
        input: in instruction_t;
        opcode: out opcode_t;
        section1: out instr_section_t;
        section2: out instr_section_t;
        section3: out instr_section_t
    );
end component instruction_register;
component state_machine is
    port(
        clock: in std_logic;
        reset: in std_logic;
        state: out state_t
    );
end component state_machine;
component rom is
    generic (
        block_size: positive;
        block_count: positive;
        rom_content: unsigned_array_t(0 to block_count - 1)(block_size - 1 downto 0)
    );
    port (
        clock: in std_logic;
        address: in unsigned((bit_count(block_count) - 1) downto 0);
        enable: in std_logic;
        output: out unsigned(block_size - 1 downto 0)
    );
end component rom;
component ula is
    generic (
        reg_size: positive
    );
    port(
        x, y : in unsigned((reg_size - 1) downto 0);
        op_selection : in unsigned(1 downto 0);
        output : out unsigned((reg_size - 1) downto 0)
    );
end component ula;
component mux is
    generic (
        input_count: positive;
        bus_width: positive
    );
    port (
        inputs: in unsigned_array_t(0 to (input_count - 1))((bus_width - 1) downto 0);
        selector: in unsigned((bit_count(input_count) - 1) downto 0);
        output: out unsigned((bus_width - 1) downto 0)
    );
end component mux;
component control_unit is
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
end component control_unit;
component status_register is
    port (
        clock: in std_logic;
        reset: in std_logic;
        write_enable: in std_logic;
        operation: in opcode_t;
        arg0: in reg_content_t;
        arg1: in reg_content_t;
        result: in alu_operand_t;
        output: out status_t
    );
end component status_register;
-- ---------------------------------------------------------------------------

-- Signals
-- ---------------------------------------------------------------------------
signal ctrl_pc_write: std_logic;
signal ctrl_ir_write: std_logic;
signal ctrl_reg_write: std_logic;
signal ctrl_status_write: std_logic;
signal ctrl_pc_source: unsigned(1 downto 0);
signal ctrl_value_write: unsigned(1 downto 0);
signal ctrl_alu_op: unsigned(1 downto 0);
signal ctrl_alu_src_a: unsigned(0 downto 0);
signal ctrl_alu_src_b: unsigned(1 downto 0);
signal ctrl_mem_read: std_logic;

signal state: state_t;
signal status: status_t;

signal pc_mux_output: progmem_address_t;
signal pc_output: progmem_address_t;
signal progmem_output: instruction_t;

signal instr_opcode: opcode_t;
signal instr_sec1: instr_section_t;
signal instr_sec2: instr_section_t;
signal instr_sec3: instr_section_t;

signal write_data_mux_output: reg_content_t;
signal rega_input: reg_content_t;
signal regb_input: reg_content_t;
signal rega_output: reg_content_t;
signal regb_output: reg_content_t;

signal alu_input0: alu_operand_t;
signal alu_input1: alu_operand_t;
signal alu_output: alu_operand_t;

-- ---------------------------------------------------------------------------

-- Instances
-- ---------------------------------------------------------------------------
begin
    state_mach: state_machine
    port map(
        clock => clock,
        reset => reset,
        state => state
    );

    ctrl: control_unit
    port map(
        operation => instr_opcode,
        state => state,
        status => status,
        pc_write => ctrl_pc_write,
        ir_write => ctrl_ir_write,
        reg_write => ctrl_reg_write,
        status_write => ctrl_status_write,
        pc_source => ctrl_pc_source,
        value_write => ctrl_value_write,
        alu_op => ctrl_alu_op,
        alu_src_a => ctrl_alu_src_a,
        alu_src_b => ctrl_alu_src_b,
        mem_read => ctrl_mem_read
    );

    status_reg: status_register
    port map(
        clock => clock,
        reset => reset,
        write_enable => ctrl_status_write,
        operation => instr_opcode,
        arg0 => rega_output,
        arg1 => regb_output,
        result => alu_output,
        output => status
    );

    pc: reg
    generic map(
        size => progmem_address_t'length
    )
    port map(
        clock => clock,
        reset => reset,
        write_enable => ctrl_pc_write,
        input => pc_mux_output,
        output => pc_output
    );

    progmem: rom
    generic map(
        block_size => instruction_t'length,
        block_count => ROM_SIZE,
        rom_content => rom_content
    )
    port map(
        clock => clock,
        address => pc_output,
        enable => ctrl_mem_read,
        output => progmem_output
    );

    instr_reg: instruction_register
    port map(
        clock => clock,
        reset => reset,
        write_enable => ctrl_ir_write,
        input => progmem_output,
        opcode => instr_opcode,
        section1 => instr_sec1,
        section2 => instr_sec2,
        section3 => instr_sec3
    );

    bank: regbank
    generic map(
        reg_count => REG_COUNT,
        reg_size => reg_content_t'length
    )
    port map(
        read_register1 => instr_sec1,
        read_register2 => instr_sec2,
        write_register => instr_sec1,
        write_data => write_data_mux_output,
        clock => clock,
        reset => reset,
        write_enable => ctrl_reg_write,
        read_data1 => rega_input,
        read_data2 => regb_input
    );

    write_data_mux: mux
    generic map(
        input_count => 3,
        bus_width => reg_content_t'length
    )
    port map(
        inputs => (
            0 => instr_sec2 & instr_sec3,
            1 => alu_output(reg_content_t'length - 1 downto 0),
            2 => regb_output
        ),
        selector => ctrl_value_write,
        output => write_data_mux_output
    );

    rega: reg
    generic map(
        size => reg_content_t'length
    )
    port map(
        clock => clock,
        reset => reset,
        write_enable => '1',
        input => rega_input,
        output => rega_output
    );

    regb: reg
    generic map(
        size => reg_content_t'length
    )
    port map(
        clock => clock,
        reset => reset,
        write_enable => '1',
        input => regb_input,
        output => regb_output
    );

    alu_input0_mux: mux
    generic map(
        input_count => 2,
        bus_width => alu_operand_t'length
    )
    port map(
        inputs => (0 => pc_output, 1 => resize(rega_output, alu_operand_t'length)),
        selector => ctrl_alu_src_a,
        output => alu_input0
    );

    alu_input1_mux: mux
    generic map(
        input_count => 3,
        bus_width => alu_operand_t'length
    )
    port map(
        inputs => (
            0 => resize(regb_output, alu_operand_t'length),
            1 => to_unsigned(1, alu_operand_t'length),
            2 => resize(instr_sec2 & instr_sec3, alu_operand_t'length)
        ),
        selector => ctrl_alu_src_b,
        output => alu_input1
    );

    alu: ula
    generic map(
        reg_size => alu_operand_t'length
    )
    port map(
        x => alu_input0,
        y => alu_input1,
        op_selection => ctrl_alu_op,
        output => alu_output
    );

    pc_mux: mux
    generic map(
        input_count => 3,
        bus_width => progmem_address_t'length
    )
    port map(
        inputs => (
            0 => alu_output,
            1 => alu_output,
            2 => pc_output(progmem_address_t'length - 1 downto progmem_address_t'length - 4) & instr_sec1 & instr_sec2 & instr_sec3
        ),
        selector => ctrl_pc_source,
        output => pc_mux_output
    );
-- ---------------------------------------------------------------------------

    TOPLVL_state <= state;
    TOPLVL_pc <= pc_output;
    TOPLVL_instruction <= instr_opcode & instr_sec1 & instr_sec2 & instr_sec3;
    TOPLVL_reg1 <= rega_input;
    TOPLVL_reg2 <= regb_input;
    TOPLVL_alu <= alu_output;

end architecture a_processador;
