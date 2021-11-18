
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.instruction.all;
use work.status.all;

entity status_register is
    port (
        clock: in std_logic;
        reset: in std_logic;
        write_enable: in std_logic;
        operation: in opcode_t;
        arg0: in reg_content_t;
        arg1: in reg_content_t;
        result: in reg_content_t;
        output: out status_t
    );
end entity;

architecture a_status_register of status_register is
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
    signal reg0_input: unsigned(7 downto 0);
    signal reg0_output: unsigned(7 downto 0);
    signal status: status_t;
begin
    reg0: reg
    generic map(size => 8)
    port map(clock => clock, reset => reset, write_enable => write_enable, input => reg0_input, output => reg0_output);

    output <= unsigned_to_status(reg0_output);

    status.carry <= '0';
    status.zero <= '0';
    status.negative <= '0';
    status.overflow <= '0';
    status.sign <= '0';
    status.half_carry <= '0';
    status.bit_copy <= '0';
    status.interrupt <= '0';

    reg0_input <= status_to_unsigned(status);

end architecture a_status_register;
