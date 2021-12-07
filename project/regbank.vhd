
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

entity regbank is
    generic (
        reg_count: positive;
        reg_size: positive
    );
    port(
        read_register1: in unsigned((bit_count(reg_count) - 1) downto 0);
        read_register2: in unsigned((bit_count(reg_count) - 1) downto 0);
        write_register: in unsigned((bit_count(reg_count) - 1) downto 0);
        write_data: in unsigned(reg_size - 1 downto 0);
        write_enable: in std_logic;
        clock: in std_logic;
        reset: in std_logic;
        read_data1: out unsigned(reg_size - 1 downto 0);
        read_data2: out unsigned(reg_size - 1 downto 0);
        output_crivo: out unsigned(reg_size - 1 downto 0)
    );
end entity regbank;

architecture a_regbank of regbank is
    component mux is
        generic (
            input_count: positive;
            bus_width: positive
        );
        port (
            inputs: in unsigned_array_t(0 to (input_count - 1))((bus_width - 1) downto 0);
            selector: in unsigned((bit_count(input_count) - 1) downto 0);
            output: out unsigned((bus_width - 1) downto 0)
        );
    end component;
    component reg is
        generic (
            size: positive
        );
        port(
            clock: in std_logic;
            reset: in std_logic;
            write_enable: in std_logic;
            input: in unsigned(size - 1 downto 0);
            output: out unsigned(size - 1 downto 0)
        );
    end component;
    component decoder is
        generic (
            output_count: positive
        );
        port (
            selector: in unsigned((bit_count(output_count) - 1) downto 0);
            enable: in std_logic;
            outputs: out std_logic_vector(0 to output_count - 1)
        );
    end component;
    signal outputs: unsigned_array_t(0 to reg_count - 1)(reg_size - 1 downto 0);
    signal write_enables: std_logic_vector(0 to reg_count - 1);
begin
    mux1: mux
    generic map(input_count => reg_count, bus_width => reg_size)
    port map(inputs => outputs, selector => read_register1, output => read_data1);
    
    mux2: mux
    generic map(input_count => reg_count, bus_width => reg_size)
    port map(inputs => outputs, selector => read_register2, output => read_data2);
    
    reg_selector: decoder
    generic map(output_count => reg_count)
    port map(selector => write_register, enable => write_enable, outputs => write_enables);
    
    generate_regs:
    for i in 0 to reg_count - 1 generate
        regx: reg
        generic map(size => reg_size)
        port map(clock => clock, reset => reset, write_enable => write_enables(i), input => write_data, output => outputs(i));
    end generate generate_regs;
    
    output_crivo <= outputs(8);
end architecture a_regbank;