
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

entity operator is
    generic (
        reg_size: positive
    );
    port (
        x, y: in unsigned((reg_size - 1) downto 0);
        sum, sub: out unsigned((reg_size - 1) downto 0);
        product, negative_x: out unsigned((reg_size - 1) downto 0)
    );
end entity;

architecture a_operator of operator is
begin
    sum <= x + y;
    sub <= x - y;
    product <= resize(x * y, reg_size);
    negative_x <= to_unsigned(1, reg_size) when signed(x) < 0 else to_unsigned(0, reg_size);
end architecture;
