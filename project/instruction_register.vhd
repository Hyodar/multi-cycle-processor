
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.instruction.all;

entity instruction_register is
    port (
        clock: in std_logic;
        reset: in std_logic;
        write_enable: in std_logic;
        input: in instruction_t;
        opcode: out opcode_t;
        section1: out instr_section_t;
        section2: out instr_section_t;
        section3: out instr_section_t
    );
end entity;

architecture a_instruction_register of instruction_register is
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
end component reg;
    signal reg0_output: unsigned(15 downto 0);
begin
    reg0: reg
    generic map(size => 16)
    port map(clock => clock, reset => reset, write_enable => write_enable, input => input, output => reg0_output);

    opcode <= reg0_output(15 downto 12);
    section1 <= reg0_output(11 downto 8);
    section2 <= reg0_output(7 downto 4);
    section3 <= reg0_output(3 downto 0);

end architecture a_instruction_register;
