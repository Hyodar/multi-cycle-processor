
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity operator is
    generic (
        reg_size: positive
    );
    port (
        x, y: in signed((reg_size - 1) downto 0);
        sum, sub: out signed((reg_size - 1) downto 0);
        greater, negative_x: out signed((reg_size - 1) downto 0)
    );
end entity;

architecture a_operator of operator is
begin
    sum <= x + y;
    sub <= x - y;
    greater <= to_signed(1, reg_size) when x > y else to_signed(0, reg_size);
    negative_x <= to_signed(1, reg_size) when x < 0 else to_signed(0, reg_size);
end architecture;
