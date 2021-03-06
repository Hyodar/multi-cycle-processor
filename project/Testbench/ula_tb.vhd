
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils.all;

entity ula_tb is
end;

architecture a_ula_tb of ula_tb is
    component ula is
        generic (
            reg_size: positive
        );
        port(
            x, y : in unsigned((reg_size - 1) downto 0);
            op_selection : in unsigned(1 downto 0);
            output : out unsigned((reg_size - 1) downto 0)
        );
    end component;

    signal x, y, output: unsigned(15 downto 0);
    signal op_selection: unsigned(1 downto 0);

begin
    uut: ula
    generic map(reg_size => 16)
    port map(x => x, y => y, op_selection => op_selection, output => output);
    
    process
    begin
        x <= unsigned(to_signed(15, 16));
        y <= unsigned(to_signed(35, 16));
        op_selection <= "00";
        wait for 10 ns;
        x <= unsigned(to_signed(-15, 16));
        y <= unsigned(to_signed(35, 16));
        op_selection <= "00";
        wait for 10 ns;
        x <= unsigned(to_signed(-15, 16));
        y <= unsigned(to_signed(-35, 16));
        op_selection <= "00";
        wait for 10 ns;
        x <= unsigned(to_signed(15, 16));
        y <= unsigned(to_signed(35, 16));
        op_selection <= "01";
        wait for 10 ns;
        x <= unsigned(to_signed(-15, 16));
        y <= unsigned(to_signed(35, 16));
        op_selection <= "01";
        wait for 10 ns;
        x <= unsigned(to_signed(-15, 16));
        y <= unsigned(to_signed(-35, 16));
        op_selection <= "01";
        wait for 10 ns;
        x <= unsigned(to_signed(15, 16));
        y <= unsigned(to_signed(35, 16));
        op_selection <= "10";
        wait for 10 ns;
        x <= unsigned(to_signed(15, 16));
        y <= unsigned(to_signed(-35, 16));
        op_selection <= "10";
        wait for 10 ns;
        x <= unsigned(to_signed(-15, 16));
        y <= unsigned(to_signed(35, 16));
        op_selection <= "11";
        wait for 10 ns;
        x <= unsigned(to_signed(15, 16));
        y <= unsigned(to_signed(35, 16));
        op_selection <= "11";
        wait for 10 ns;
        wait;
    end process;
end architecture;