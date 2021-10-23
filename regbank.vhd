
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.signed_array.all;

entity regbank is
    generic (
        reg_count: positive;
        reg_size: positive
    );
    port(
        read_register1: in unsigned((integer(ceil(log2(real(reg_count)))) - 1) downto 0);
        read_register2: in unsigned((integer(ceil(log2(real(reg_count)))) - 1) downto 0);
        write_register: in unsigned((integer(ceil(log2(real(reg_count)))) - 1) downto 0);
        write_data: in signed(reg_size - 1 downto 0);
        write_enable: in std_logic;
        clock: in std_logic;
        reset: in std_logic;
        read_data1: out signed(reg_size - 1 downto 0);
        read_data2: out signed(reg_size - 1 downto 0)
    );
end entity regbank;

architecture a_regbank of regbank is
    component signed_mux is
        generic (
            input_count: positive;
            bus_width: positive
        );
        port (
            inputs: in signed_array_t(0 to (input_count - 1))((bus_width - 1) downto 0);
            selector: in unsigned((integer(ceil(log2(real(input_count)))) - 1) downto 0);
            output: out signed((bus_width - 1) downto 0)
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
            input: in signed(size - 1 downto 0);
            output: out signed(size - 1 downto 0)
        );
    end component;
    component decoder is
        generic (
            output_count: positive
        );
        port (
            selector: in unsigned((integer(ceil(log2(real(output_count)))) - 1) downto 0);
            enable: in std_logic;
            outputs: out std_logic_vector(0 to output_count - 1)
        );
    end component;
    signal outputs: signed_array_t(0 to reg_count - 1)(reg_size - 1 downto 0);
    signal write_enables: std_logic_vector(0 to reg_count - 1);
begin
    mux1: signed_mux
    generic map(input_count => reg_count, bus_width => reg_size)
    port map(inputs => outputs, selector => read_register1, output => read_data1);
    
    mux2: signed_mux
    generic map(input_count => reg_count, bus_width => reg_size)
    port map(inputs => outputs, selector => read_register2, output => read_data2);
    
    reg_selector: decoder
    generic map(output_count => reg_count)
    port map(selector => write_register, enable => write_enable, outputs => write_enables);

    -- $0: fica com 0 a partir do reset e não pode ser sobrescrito
    reg_zero: reg
    generic map(size => reg_size)
    port map(clock => clock, reset => reset, write_enable => '0', input => write_data, output => outputs(0));
    
    generate_regs:
    for i in 1 to reg_count - 1 generate
        regx: reg
        generic map(size => reg_size)
        port map(clock => clock, reset => reset, write_enable => write_enables(i), input => write_data, output => outputs(i));
    end generate generate_regs;
    
end architecture a_regbank;