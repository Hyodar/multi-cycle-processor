
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.unsigned_array.all;
use work.opcodes.all;

entity control_unit is
    generic (
        block_size: positive;
        block_count: positive
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
            input: in signed(size - 1 downto 0);
            output: out signed(size - 1 downto 0)
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
            address: in unsigned((integer(ceil(log2(real(block_count)))) - 1) downto 0);
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
    
    signal pc0_output: signed(integer(ceil(log2(real(block_count)))) - 1 downto 0);
    signal pc0_input: signed(integer(ceil(log2(real(block_count)))) - 1 downto 0);
    signal pc0_write_enable: std_logic;
    signal pc0_output_unsigned: unsigned(integer(ceil(log2(real(block_count)))) - 1 downto 0);
    
    signal instruction: unsigned(block_size - 1 downto 0);
    signal state: std_logic;
    
    signal opcode: unsigned(OPCODE_SIZE - 1 downto 0);
    signal jump_enable: std_logic;
    signal nop_enable: std_logic;
    
    signal jump_address: unsigned(integer(ceil(log2(real(block_count)))) - 1 downto 0);

begin
    state_machine: t_flipflop
    port map(clock => clock, reset => reset, input => '1', output => state);
    
    pc0: reg
    generic map(size => integer(ceil(log2(real(block_count)))))
    port map(clock => clock, reset => reset, write_enable => pc0_write_enable, input => pc0_input, output => pc0_output);
    
    rom0: rom
    generic map(block_size => 12, block_count => 128, rom_content => (
            0 => "000000000000", -- nop;
            1 => "000000000000", -- nop;
            2 => "010000000000", -- opcode desconhecido
            3 => "000000000000", -- nop;
            4 => "000000000000", -- nop;
            5 => "111100000111", -- jump 7;
            6 => "000000000000", -- nop;
            7 => "000000000000", -- nop;
            8 => "111100000000", -- jump 0;
            9 => "000000000000", -- nop;
            10 => "000000000000", -- nop;
            -- abaixo: casos omissos => (zero em todos os bits)
            others => (others => '0')
        ))
    port map(clock => clock, address => pc0_output_unsigned, output => instruction);

    pc0_write_enable <= '1' when (state = '1' and write_enable = '1' and opcode_exception = '0') else '0';
    pc0_output_unsigned <= unsigned(pc0_output);
    opcode <= instruction(block_size - 1 downto block_size - OPCODE_SIZE);
    
    jump_enable <= '1' when opcode = OP_JUMP else '0';
    nop_enable <= '1' when opcode = OP_NOP else '0';
    opcode_exception <= '0' when (jump_enable or nop_enable) else '1';
    
    jump_address <= instruction(integer(ceil(log2(real(block_count)))) - 1 downto 0);
    pc0_input <= pc0_output + 1 when jump_enable = '0' else signed(jump_address);
    
    -- saída para debugging
    output <= instruction;
    
end architecture a_control_unit;