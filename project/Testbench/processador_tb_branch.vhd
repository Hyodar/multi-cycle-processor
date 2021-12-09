library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils.all;
use work.instruction.all;
use work.state.all;

entity processador_tb_branch is
end entity;

architecture a_processador_tb_branch of processador_tb_branch is

    component processador is
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
            TOPLVL_alu: out reg_content_t;
            TOPLVL_crivo: out reg_content_t
        );
    end component processador;

    constant period_time: time := 100 ns;
    signal finished: std_logic := '0';

    signal clock: std_logic;
    signal reset: std_logic;
    signal TOPLVL_state: state_t;
    signal TOPLVL_pc: progmem_address_t;
    signal TOPLVL_instruction: instruction_t;
    signal TOPLVL_reg1: reg_content_t;
    signal TOPLVL_reg2: reg_content_t;
    signal TOPLVL_alu: reg_content_t;
    signal TOPLVL_crivo: reg_content_t;

begin
    processor: processador
    generic map(
        rom_content => (
            0 => B"0101_0011_0000_0000",   -- ldi r3,0x00        | r3 = 0;
            1 => B"0101_0100_0000_0000",   -- ldi r4,0x00        | r4 = 0;
            2 => B"0001_0100_0011_0000",   -- label1: add r4,r3  | do { r4 += r3;
            3 => B"0101_0001_0000_0001",   -- ldi r1,0x01        | r1 = 1;
            4 => B"0001_0011_0001_0000",   -- add r3,r1          | r3 += r1;
            5 => B"0111_0011_0001_1110",   -- cpi r3,30          |
            6 => B"1010_1111_1111_1011",   -- brlo label1        | } while (r3 < 30);
            7 => B"0100_0101_0100_0000",   -- mov r5,r4          | r5 = r4;
            others => B"0000_0000_0000_0000"
        )
    )
    port map(
        clock => clock,
        reset => reset,
        TOPLVL_state => TOPLVL_state,
        TOPLVL_pc => TOPLVL_pc,
        TOPLVL_instruction => TOPLVL_instruction,
        TOPLVL_reg1 => TOPLVL_reg1,
        TOPLVL_reg2 => TOPLVL_reg2,
        TOPLVL_alu => TOPLVL_alu,
        TOPLVL_crivo => TOPLVL_crivo
    );

    global_reset: process
    begin
        reset <= '1';
        wait for period_time * 2;
        reset <= '0';
        wait;
    end process;
    
    sim_time_proc: process
    begin
        wait for 100 us;
        finished <= '1';
        wait;
    end process sim_time_proc;
    
    clock_proc: process
    begin
        while finished /= '1' loop
            clock <= '0';
            wait for period_time / 2;
            clock <= '1';
            wait for period_time / 2;
        end loop;
        wait;
    end process clock_proc;

    process
    begin
        wait for 500 ns;
        wait;
    end process;

end architecture a_processador_tb_branch;