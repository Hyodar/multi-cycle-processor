
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;
use work.instruction.all;

entity processador_tb is
end entity;

architecture a_processador_tb of processador_tb is

component processador is
    generic(
        rom_content: unsigned_array_t(0 to ROM_SIZE - 1)(instruction_t'length - 1 downto 0)
    );
    port(
        clock: in std_logic;
        reset: in std_logic
    );
end component processador;

constant period_time: time := 100 ns;
signal finished: std_logic := '0';

signal clock: std_logic;
signal reset: std_logic;

begin
    -- SUB, SUBI, MOV
    -- NOP, ADD, LDI, JUMP
    processor: processador
    generic map(
        rom_content => (
            0 => B"0101_0001_1111_1111",  -- ldi r1,0xFF        | r1 = 255;
            1 => B"0101_0010_0000_0001",  -- ldi r2,0x1         | r2 = 1;
            2 => B"0001_0001_0010_0000",  -- add r1,r2          | r1 += r2;
            3 => B"0010_0001_0010_0000",  -- sub r1,r2          | r1 -= r2;
            4 => B"0011_0001_0000_0001",  -- subi r1,0x1        | r1 -= 1;
            5 => B"0011_0001_0000_0001",  -- subi r1,0x1        | r1 -= 1;
            -- 5 => B"0100_0010_0001_0000",  -- mov r2,r1       | r2 <- r1;
            6 => B"1111_0000_0000_0110",  -- jmp 6              | while (true);
            7 => B"0100_0001_0010_0000",  -- mov r1,r2          | r1 <- r2;
           --  7 => B"0100_0001_0010_0000",  -- nop
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