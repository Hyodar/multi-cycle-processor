
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

entity processor_tb is
end;

architecture a_processor_tb of processor_tb is
    component processor is
        generic (
            reg_size: positive;
            reg_count: positive
        );
        port (
            selector: in unsigned(1 downto 0);
            immediate: in unsigned((reg_size - 1) downto 0);
            is_immediate: in unsigned(0 downto 0);
            reg0: in unsigned((bit_count(reg_count) - 1) downto 0);
            reg1: in unsigned((bit_count(reg_count) - 1) downto 0);
            reg2: in unsigned((bit_count(reg_count) - 1) downto 0);
            write_enable: in std_logic;
            clock: in std_logic;
            reset: in std_logic;
            ula_out: out unsigned((reg_size - 1) downto 0);
            read_data1: out unsigned((reg_size - 1) downto 0);
            read_data2: out unsigned((reg_size - 1) downto 0)
        );
    end component processor;

    constant period_time: time := 100 ns;
    signal finished: std_logic := '0';
    
    signal selector: unsigned(1 downto 0);
    signal immediate: unsigned(15 downto 0);
    signal is_immediate: unsigned(0 downto 0);
    signal reg0: unsigned(2 downto 0);
    signal reg1: unsigned(2 downto 0);
    signal reg2: unsigned(2 downto 0);
    signal write_enable: std_logic;
    
    signal clock: std_logic;
    signal reset: std_logic;
    signal ula_out: unsigned(15 downto 0);

begin
    uut: processor
    generic map(reg_size => 16, reg_count => 8)
    port map(selector => selector, immediate => immediate, is_immediate => is_immediate, reg0 => reg0, reg1 => reg1, reg2 => reg2, write_enable => write_enable, clock => clock, reset => reset, ula_out => ula_out);
    
    global_reset: process
    begin
        reset <= '1';
        wait for period_time * 2;
        reset <= '0';
        
        -- teste do reset depois de operações
        wait for 1 us;
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

        -- addi $1,$2,10
        is_immediate <= "1";
        write_enable <= '1';
        immediate <= to_unsigned(10, 16);
        selector <= "00";
        reg0 <= to_unsigned(1, 3);
        reg1 <= to_unsigned(2, 3);
        reg2 <= to_unsigned(3, 3);
        wait for 100 ns;
        
        -- addi $0,$1,10
        is_immediate <= "1";
        write_enable <= '1';
        immediate <= to_unsigned(10, 16);
        selector <= "00";
        reg0 <= to_unsigned(0, 3);
        reg1 <= to_unsigned(1, 3);
        reg2 <= to_unsigned(3, 3);
        wait for 100 ns;
        
        -- add $2,$1,$1
        is_immediate <= "0";
        write_enable <= '1';
        immediate <= to_unsigned(10, 16);
        selector <= "00";
        reg0 <= to_unsigned(2, 3);
        reg1 <= to_unsigned(1, 3);
        reg2 <= to_unsigned(1, 3);
        wait for 100 ns;
        
        -- add $2,$1,$0
        is_immediate <= "0";
        write_enable <= '1';
        immediate <= to_unsigned(10, 16);
        selector <= "00";
        reg0 <= to_unsigned(2, 3);
        reg1 <= to_unsigned(1, 3);
        reg2 <= to_unsigned(0, 3);
        wait for 100 ns;
        
        -- add $3,$2,$1 (com write_enable falso, não deve escrever)
        is_immediate <= "0";
        write_enable <= '0';
        immediate <= to_unsigned(10, 16);
        selector <= "00";
        reg0 <= to_unsigned(3, 3);
        reg1 <= to_unsigned(2, 3);
        reg2 <= to_unsigned(1, 3);
        wait for 100 ns;
        
        wait;
    end process;
end architecture;