
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
    processor: processador
    generic map(
        rom_content => (
            0 => B"0100_0001_1111_1111",  -- ldi r1,0xFF        | r1 = 255;
            1 => B"1111_0000_0000_0001",  -- jmp 1              | while (true);
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