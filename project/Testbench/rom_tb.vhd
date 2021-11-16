
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;
use work.instruction.all;

entity rom_tb is
end entity;

architecture a_rom_tb of rom_tb is

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

constant period_time: time := 100 ns;
signal finished: std_logic := '0';

signal clock: std_logic;
signal reset: std_logic;
signal address: unsigned(15 downto 0);
signal pc_output: unsigned(15 downto 0);
signal output: unsigned(15 downto 0);

begin
    pc: reg
    generic map(
        size => 16
    )
    port map(
        clock => clock,
        reset => reset,
        write_enable => '1',
        input => address,
        output => pc_output
    );

    mem: rom
    generic map(
        block_size => 16,
        block_count => 65536,
        rom_content => (
            0 => B"0101_0001_1111_1111",  -- ldi r1,0xFF        | r1 = 255;
            1 => B"0101_0010_0000_0001",  -- ldi r2,0x1         | r2 = 1;
            2 => B"0001_0001_0010_0000",  -- add r1,r2          | r1 += r2;
            3 => B"1111_0000_0000_0011",  -- jmp 3              | while (true);
            4 => B"0001_0010_0001_0000",  -- add r2,r1          | r2 += r1;
            5 => B"0000_0000_0000_0000",  -- nop                |
            others => B"0000_0000_0000_0000"
        )
    )
    port map(
        clock => clock,
        address => pc_output,
        output => output,
        enable => '1'
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
        address <= B"0000_0000_0000_0000";
        -- address <= "000";
        wait for 950 ns;
        address <= B"0000_0000_0000_0001";
        -- address <= "001";
        wait for 1000 ns;
        wait;
    end process;

end architecture a_rom_tb;