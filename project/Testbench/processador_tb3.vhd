
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils.all;
use work.instruction.all;
use work.state.all;

entity processador_tb3 is
end entity;

architecture a_processador_tb3 of processador_tb3 is

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
            0 => B"0110_0011_0000_0010",   -- ldi r3,0x02        | r3 = 2;
            1 => B"0110_0100_0000_1010",   -- ldi r4,0x0A        | r4 = 10;
            2 => B"1101_0011_0100_0000",   -- st (r4), r3        | mem[r4] = r3;
            3 => B"1100_0101_0100_0001",   -- ld r5, (r4)        | r5 = mem[r4];
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

end architecture a_processador_tb3;