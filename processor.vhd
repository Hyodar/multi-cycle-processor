
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.unsigned_array.all;
use work.signed_array.all;

entity processor is
    generic (
        reg_size: positive;
        reg_count: positive
    );
    port (
        selector: in unsigned(1 downto 0);
        immediate: in signed((reg_size - 1) downto 0); -- testpin
        is_immediate: in unsigned(0 downto 0); -- mux0_selector
        reg0: in unsigned((integer(ceil(log2(real(reg_count)))) - 1) downto 0);
        reg1: in unsigned((integer(ceil(log2(real(reg_count)))) - 1) downto 0);
        reg2: in unsigned((integer(ceil(log2(real(reg_count)))) - 1) downto 0);
        write_enable: in std_logic;
        clock: in std_logic;
        reset: in std_logic;
        ula_out: out signed((reg_size - 1) downto 0);
        read_data1: out signed((reg_size - 1) downto 0);
        read_data2: out signed((reg_size - 1) downto 0)
    );
end entity processor;

architecture a_processor of processor is
    component ula is
        generic (
            reg_size: positive
        );
        port(
            x, y : in signed((reg_size - 1) downto 0);
            op_selection : in unsigned(1 downto 0);
            output : out signed((reg_size - 1) downto 0)
        );
    end component;
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
    component regbank is
        generic (
            reg_count: positive;
            reg_size: positive
        );
        port(
            read_register1: in unsigned((integer(ceil(log2(real(reg_count)))) - 1) downto 0);
            read_register2: in unsigned((integer(ceil(log2(real(reg_count)))) - 1) downto 0);
            write_register: in unsigned((integer(ceil(log2(real(reg_count)))) - 1) downto 0);
            write_data: in signed((reg_size - 1) downto 0);
            write_enable: in std_logic;
            clock: in std_logic;
            reset: in std_logic;
            read_data1: out signed((reg_size - 1) downto 0);
            read_data2: out signed((reg_size - 1) downto 0)
        );
    end component;
    signal mux0_output: signed((reg_size - 1) downto 0);
    signal ula0_output: signed((reg_size - 1) downto 0);
begin

    ula0: ula
    generic map(reg_size => reg_size)
    port map(x => read_data1, y => mux0_output, op_selection => selector, output => ula0_output);
    mux0: signed_mux
    generic map(input_count => 2, bus_width => reg_size)
    port map(inputs => (0 => read_data2, 1 => immediate), selector => is_immediate, output => mux0_output);
    regbank0: regbank
    generic map(reg_count => reg_count, reg_size => reg_size)
    port map(read_register1 => reg1, read_register2 => reg2, write_register => reg0, write_data => ula0_output, write_enable => write_enable, clock => clock, reset => reset, read_data1 => read_data1, read_data2 => read_data2);

    -- porta ula_out para debugging
    ula_out <= ula0_output;
    
end architecture a_processor;
