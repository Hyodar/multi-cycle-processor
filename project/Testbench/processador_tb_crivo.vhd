
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.utils.all;
use work.instruction.all;
use work.state.all;

entity processador_tb_crivo is
end entity;

architecture a_processador_tb_crivo of processador_tb_crivo is

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
            0 => B"0101_0010_0010_0000",     -- | ldi r2,0x20                   | r2 = 32
            1 => B"0101_0000_0000_0000",     -- | ldi r0,0x0                    | r0 = 0
            2 => B"0101_0001_0000_0001",     -- | ldi r1,0x1                    | r1 = 1
            3 => B"0101_1110_0000_0001",     -- | ldi r14,0x1                   | r14 = 1
            4 => B"0110_0010_1110_0000",     -- | loop1s: cp r2,r14             | loop1s:
            5 => B"1010_0000_0000_0011",     -- | brlo loop1e                   |   if (r2 < r14) goto loop1e
            6 => B"1100_1110_1110_0000",     -- | st r14,r14                    |   MEM[r14] = r14
            7 => B"0001_1110_0001_0000",     -- | add r14,r1                    |   r14 += r1
            8 => B"1111_0000_0000_0100",     -- | jmp loop1s                    | goto loop1s
            9 => B"0101_1110_0000_0001",     -- | loop1e: ldi r14,0x1           | loop1e: r14 = 1
            
            10 => B"0101_0101_0000_0001",     -- | ldi r5,0x1                    | r5 = 1
            
            11 => B"0110_0010_0101_0000",     -- | loop2s: cp r2,r5              | loop2s:
            12 => B"1010_0000_0000_1010",     -- | brlo loop2e                   |   if (r2 < r5) goto loop2e
            13 => B"0100_0110_1110_0000",     -- | mov r6,r14                    |   r6 = r14
            14 => B"0001_1110_0001_0000",     -- | add r14,r1                    |   r14 += r1
            15 => B"0100_0101_0000_0000",     -- | mov r5,r0                     |   r5 = r0
            16 => B"0100_1111_0001_0000",     -- | mov r15,r1                    |   r15 = r1
            17 => B"0110_1110_1111_0000",     -- | sqradds: cp r14,r15           |   sqradds:
            18 => B"1010_0000_0000_0011",     -- | brlo sqradde                  |       if (r14 < r15) goto sqradde
            19 => B"0001_0101_1110_0000",     -- | add r5,r14                    |       r5 += r14
            20 => B"0001_1111_0001_0000",     -- | add r15,r1                    |       r15 += r1
            21 => B"1111_0000_0001_0001",     -- | jmp sqradds                   |   goto sqradds
            22 => B"1111_0000_0000_1011",     -- | sqradde: jmp loop2s           |   sqradde: goto loop2s
            23 => B"0101_1110_0000_0010",     -- | loop2e: ldi r14,0x2           | loop2e: r14 = 2
            
            24 => B"1011_0101_1110_0000",     -- | ld r5,r14                     | r5 = MEM[r14]
            25 => B"0100_0111_0101_0000",     -- | mov r7,r5                     | r7 = r5
            26 => B"0001_0111_0101_0000",     -- | add r7,r5                     | r7 += r5
            
            27 => B"0110_0110_0101_0000",     -- | loop3s: cp r6,r5              | loop3s:
            28 => B"1010_0000_0001_0111",     -- | brlo loop3e                   |   if (r6 < r5) goto loop3e
            29 => B"0100_1111_1110_0000",     -- | mov r15,r14                   |   r15 = r14
            30 => B"0001_1111_0001_0000",     -- | add r15,r1                    |   r15 += r1
            31 => B"0110_0010_1111_0000",     -- | loop4s: cp r2,r15             |   loop4s:
            32 => B"1010_0000_0000_1001",     -- | brlo loop4e                   |       if (r2 < r15) goto loop4e
            33 => B"0110_1111_0111_0000",     -- | cp r15,r7                     |
            34 => B"1001_0000_0000_0010",     -- | brne cursor_larger            |       if (r15 != r7) goto cursor_larger
            35 => B"1100_0000_1111_0000",     -- | st r15,r0                     |       MEM[r15] = r0
            36 => B"0001_0111_0101_0000",     -- | add r7,r5                     |       r7 += r5
            37 => B"0110_1111_0111_0000",     -- | cursor_larger: cp r15,r7      |       cursor_larger:
            38 => B"1010_0000_0000_0001",     -- | brlo cursor_smaller           |       if (r15 < r7) goto cursor_smaller
            39 => B"0001_0111_0101_0000",     -- | add r7,r5                     |       r7 += r5
            40 => B"0001_1111_0001_0000",     -- | cursor_smaller: add r15,r1    |       cursor_smaller: r15 += r1
            41 => B"1111_0000_0001_1111",     -- | jmp loop4s                    |   goto loop4s
            42 => B"0001_1110_0001_0000",     -- | loop4e: add r14,r1            |   loop4e: r14 += r1
            43 => B"1011_0101_1110_0000",     -- | ld r5,r14                     |   r5 = MEM[r14]
            44 => B"0110_0101_0000_0000",     -- | loop5s: cp r5,r0              |   loop5s:
            45 => B"1001_0000_0000_0011",     -- | brne loop5e                   |       if (r5 != r0) goto loop5e
            46 => B"0001_1110_0001_0000",     -- | add r14,r1                    |       r14 += r1
            47 => B"1011_0101_1110_0000",     -- | ld r5,r14                     |       r5 = MEM[r14]
            48 => B"1111_0000_0010_1100",     -- | jmp loop5s                    |   goto loop5s
            49 => B"0100_0111_0101_0000",     -- | loop5e: mov r7,r5             |   loop5e: r7 = r5
            50 => B"0001_0111_0101_0000",     -- | add r7,r5                     |   r7 += r5
            51 => B"1111_0000_0001_1011",     -- | jmp loop3s                    | goto loop3s
            52 => B"0101_1110_0000_0010",     -- | loop3e: ldi r14,0x2           | loop3e: r14 = 2
            
            53 => B"0110_0010_1110_0000",     -- | loop6s: cp r2,r14             | loop6s:
            54 => B"1010_0000_0000_0011",     -- | brlo end                      |   if (r2 < r14) goto end
            55 => B"1011_1000_1110_0000",     -- | ld r8,r14                     |   r8 = MEM[r14]
            56 => B"0001_1110_0001_0000",     -- | add r14,r1                    |   r14 += r1
            57 => B"1111_0000_0011_0101",     -- | jmp loop6s                    | goto loop6s
            58 => B"1111_0000_0011_1010",     -- | end: jmp end                  | end: goto end
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

end architecture a_processador_tb_crivo;