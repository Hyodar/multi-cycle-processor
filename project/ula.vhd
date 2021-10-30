
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.unsigned_array.all;

entity ula is
    generic (
        reg_size: positive
    );
    port(
        x, y : in unsigned((reg_size - 1) downto 0);
        op_selection : in unsigned(1 downto 0);
        output : out unsigned((reg_size - 1) downto 0)
    );
end entity;

architecture a_ula of ula is
    component mux is
        generic (
            input_count: positive;
            bus_width: positive
        );
        port (
            inputs: in unsigned_array_t(0 to (input_count - 1))((bus_width - 1) downto 0);
            selector: in unsigned((integer(ceil(log2(real(input_count)))) - 1) downto 0);
            output: out unsigned((bus_width - 1) downto 0)
        );
    end component;
    component operator is
        generic (
            reg_size: positive
        );
        port (
            x, y: in unsigned((reg_size - 1) downto 0);
            sum, sub: out unsigned((reg_size - 1) downto 0);
            greater, negative_x: out unsigned((reg_size - 1) downto 0)
        );
    end component;
    signal sum_result, sub_result, greater_result, negative_result : unsigned((reg_size - 1) downto 0);
begin
    operator0: operator
    generic map(reg_size => reg_size)
    port map(x => x, y => y, sum => sum_result, sub => sub_result, greater => greater_result, negative_x => negative_result);
    mux0: mux
    generic map(input_count => 4, bus_width => reg_size)
    port map(inputs => (0 => sum_result, 1 => sub_result, 2 => greater_result, 3 => negative_result), selector => op_selection, output => output);
end architecture;
