
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils.all;
use work.instruction.all;
use work.state.all;

entity processador_tb is
end entity;

architecture a_processador_tb of processador_tb is

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
        TOPLVL_alu: out reg_content_t
    );
end component processador;

constant period_time: time := 100 ns;
signal finished: std_logic := '0';

signal clock: std_logic;
signal reset: std_logic;

begin
    processor: processador
    generic map(
        rom_content => (
            0 => B"0101_0011_0000_0101",   -- ldi r3,0x05        | r1 = 255;
            1 => B"0101_0100_0000_1000",   -- ldi r4,0x08        | r2 = 1;
            2 => B"0001_0011_0100_0000",   -- label1: add r3,r4  | label1: r3 += r4;
            3 => B"0100_0101_0011_0000",   -- mov r5,r3          | r5 = r3;
            4 => B"0011_0101_0000_0001",   -- subi r5,0x01       | r5 -= 1;
            5 => B"1111_0000_0001_0100",   -- jmp label2         | goto label2;
            20 => B"0100_0011_0101_0000",  -- label2: mov r3,r5  | label2: r5 = r3;
            21 => B"1111_0000_0000_0010",  -- jmp label1         | goto label1;
            others => B"0000_0000_0000_0000"
        )
    )
    port map(
        clock => clock,
        reset => reset
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
        wait for 10 us;
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

end architecture a_processador_tb;