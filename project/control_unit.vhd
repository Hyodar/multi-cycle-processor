
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;
use work.opcodes.all;

entity control_unit is
    generic (
        block_size: positive;
        block_count: positive;
        rom_content: unsigned_array_t(0 to block_count - 1)(block_size - 1 downto 0)
    );
    port (
        write_enable: in std_logic;
        reset: in std_logic;
        clock: in std_logic;
        output: out unsigned(block_size - 1 downto 0);
        opcode_exception: out std_logic
    );
end entity;

architecture a_control_unit of control_unit is
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
    end component;
    component rom is
        generic (
            block_size: positive;
            block_count: positive;
            rom_content: unsigned_array_t(0 to block_count - 1)(block_size - 1 downto 0)
        );
        port (
            clock: in std_logic;
            address: in unsigned((bit_count(block_count) - 1) downto 0);
            output: out unsigned(block_size - 1 downto 0)
        );
    end component;
    component t_flipflop is
        port (
            clock: in std_logic;
            reset: in std_logic;
            input: in std_logic;
            output: out std_logic
        );
    end component;
    
    signal pc0_output: unsigned(bit_count(block_count) - 1 downto 0);
    signal pc0_input: unsigned(bit_count(block_count) - 1 downto 0);
    signal pc0_write_enable: std_logic;
    signal pc0_output_unsigned: unsigned(bit_count(block_count) - 1 downto 0);
    
    signal instruction: unsigned(block_size - 1 downto 0);
    signal state: std_logic;
    
    signal opcode: unsigned(OPCODE_SIZE - 1 downto 0);
    signal jump_enable: std_logic;
    signal nop_enable: std_logic;
    
    signal jump_address: unsigned(bit_count(block_count) - 1 downto 0);

begin
    state_machine: t_flipflop
    port map(clock => clock, reset => reset, input => '1', output => state);
    
    pc0: reg
    generic map(size => bit_count(block_count))
    port map(clock => clock, reset => reset, write_enable => pc0_write_enable, input => pc0_input, output => pc0_output);
    
    rom0: rom
    generic map(block_size => block_size, block_count => block_count, rom_content => rom_content)
    port map(clock => clock, address => pc0_output_unsigned, output => instruction);

    pc0_write_enable <= '1' when (state = '1' and write_enable = '1' and opcode_exception = '0') else '0';
    pc0_output_unsigned <= unsigned(pc0_output);
    opcode <= instruction(block_size - 1 downto block_size - OPCODE_SIZE);
    
    jump_enable <= '1' when opcode = OP_JUMP else '0';
    nop_enable <= '1' when opcode = OP_NOP else '0';
    opcode_exception <= '0' when (jump_enable or nop_enable) else '1';
    
    jump_address <= instruction(bit_count(block_count) - 1 downto 0);
    pc0_input <= pc0_output + 1 when jump_enable = '0' else unsigned(jump_address);
    
    -- saída para debugging
    output <= instruction;
    
end architecture a_control_unit;
