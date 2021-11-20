
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils.all;
use work.instruction.all;
use work.state.all;

entity processador_tb5 is
end entity;

architecture a_processador_tb5 of processador_tb5 is

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
    signal TOPLVL_state: state_t;
    signal TOPLVL_pc: progmem_address_t;
    signal TOPLVL_instruction: instruction_t;
    signal TOPLVL_reg1: reg_content_t;
    signal TOPLVL_reg2: reg_content_t;
    signal TOPLVL_alu: reg_content_t;

begin
    processor: processador
    generic map(
        rom_content => (
            0 => B"0110_0010_0010_0000",     -- | ldi r2,0x20               | r2 = 32
            1 => B"0110_0000_0000_0000",     -- | ldi r0,0x0                | r0 = 0
            2 => B"0110_0001_0000_0001",     -- | ldi r1,0x1                | r1 = 1
            3 => B"0110_0011_0000_0001",     -- | ldi r3,0x1                | r3 = 1
            
            4 => B"0111_0010_0011_0000",     -- | loop1s: cp r2,r3          | loop1s: 
            5 => B"1011_0000_0000_0011",     -- | brlo loop1e               |   if (r2 < r3) goto loop1e
            6 => B"1101_0011_0011_0000",     -- | st r3,r3                  |   MEM[r3] = r3
            7 => B"0001_0011_0001_0000",     -- | add r3,r1                 |   r3 += r1
            8 => B"1111_0000_0000_0100",     -- | jmp loop1s                | goto loop1s
            9 => B"0110_0011_0000_0001",     -- | loop1e: ldi r3,0x1        | loop1e: r3 = 1
            
            10 => B"0110_0101_0000_0001",    -- | ldi r5,0x1                | r5 = 1
            
            11 => B"0111_0010_0101_0000",    -- | loop2s: cp r2,r5          | loop2s: 
            12 => B"1011_0000_0000_0101",    -- | brlo loop2e               |   if (r2 < r5) goto loop2e
            13 => B"0101_0110_0011_0000",    -- | mov r6,r3                 |   r6 = r3
            14 => B"0001_0011_0001_0000",    -- | add r3,r1                 |   r3 += r1
            15 => B"0101_0101_0011_0000",    -- | mov r5,r3                 |   r5 = r3
            16 => B"0100_0101_0101_0000",    -- | mul r5,r5                 |   r5 *= r5
            17 => B"1111_0000_0000_1011",    -- | jmp loop2s                | goto loop2s
            18 => B"0110_0011_0000_0010",    -- | loop2e: ldi r3,0x2        | loop2e: r3 = 2
            
            19 => B"1100_0101_0011_0000",    -- | ld r5,r3                  | r5 = MEM[r3]
            20 => B"0101_0111_0101_0000",    -- | mov r7,r5                 | r7 = r5
            21 => B"0001_0111_0101_0000",    -- | add r7,r5                 | r7 += r5
            
            22 => B"0111_0110_0101_0000",    -- | loop3s: cp r6,r5          | loop3s: 
            23 => B"1011_0000_0001_0111",    -- | brlo loop3e               |   if (r6 < r5) goto loop3e
            24 => B"0101_0100_0011_0000",    -- | mov r4,r3                 |   r4 = r3
            25 => B"0001_0100_0001_0000",    -- | add r4,r1                 |   r4 += r1
            26 => B"0111_0010_0100_0000",    -- | loop4s: cp r2,r4          |   loop4s: 
            27 => B"1011_0000_0000_1001",    -- | brlo loop4e               |       if (r2 < r4) goto loop4e
            28 => B"0111_0100_0111_0000",    -- | cp r4,r7                  | 
            29 => B"1010_0000_0000_0010",    -- | brne cursor_larger        |       if (r4 != r7) goto cursor_larger
            30 => B"1101_0000_0100_0000",    -- | st r4,r0                  |       MEM[r4] = r0
            31 => B"0001_0111_0101_0000",    -- | add r7,r5                 |       r7 += r5
            32 => B"0111_0100_0111_0000",    -- | cursor_larger: cp r4,r7   |       cursor_larger: 
            33 => B"1011_0000_0000_0001",    -- | brlo cursor_smaller       |       if (r4 < r7) goto cursor_smaller
            34 => B"0001_0111_0101_0000",    -- | add r7,r5                 |       r7 += r5
            35 => B"0001_0100_0001_0000",    -- | cursor_smaller: add r4,r1 |       cursor_smaller: r4 += r1
            36 => B"1111_0000_0001_1010",    -- | jmp loop4s                |   goto loop4s
            37 => B"0001_0011_0001_0000",    -- | loop4e: add r3,r1         |   loop4e: r3 += r1
            
            38 => B"1100_0101_0011_0000",    -- | ld r5,r3                  |   r5 = MEM[r3]
            39 => B"0111_0101_0000_0000",    -- | loop5s: cp r5,r0          |   loop5s: 
            40 => B"1010_0000_0000_0011",    -- | brne loop5e               |       if (r5 != r0) goto loop5e
            41 => B"0001_0011_0001_0000",    -- | add r3,r1                 |       r3 += r1
            42 => B"1100_0101_0011_0000",    -- | ld r5,r3                  |       r5 = MEM[r3]
            43 => B"1111_0000_0010_0111",    -- | jmp loop5s                |   goto loop5s
            44 => B"0101_0111_0101_0000",    -- | loop5e: mov r7,r5         |   loop5e: r7 = r5
            
            45 => B"0001_0111_0101_0000",    -- | add r7,r5                 |   r7 += r5
            46 => B"1111_0000_0001_0110",    -- | jmp loop3s                | goto loop3s
            47 => B"0110_0011_0000_0001",    -- | loop3e: ldi r3,0x1        | loop3e: r3 = 1
            
            48 => B"0111_0010_0011_0000",    -- | loop6s: cp r2,r3          | loop6s: 
            49 => B"1011_0000_0000_0011",    -- | brlo end                  |   if (r2 < r3) goto end
            50 => B"1100_1000_0011_0000",    -- | ld r8,r3                  |   r8 = MEM[r3]
            51 => B"0001_0011_0001_0000",    -- | add r3,r1                 |   r3 += r1
            52 => B"1111_0000_0011_0000",    -- | jmp loop6s                | goto loop6s
            
            53 => B"1111_0000_0011_0101",    -- | end: jmp end              | end: goto end
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
        TOPLVL_alu => TOPLVL_alu
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
        -- final: ~300 us
        wait for 400 us;
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

end architecture a_processador_tb5;