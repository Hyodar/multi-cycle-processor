
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package status is
    type status_t is record
        carry: std_logic;
        zero: std_logic;
        negative: std_logic;
        overflow: std_logic;
        sign: std_logic;
        half_carry: std_logic;
        bit_copy: std_logic;
        interrupt: std_logic;
    end record status_t;

    function status_to_unsigned(s: status_t) return unsigned;
    function unsigned_to_status(u: unsigned) return status_t;
end package;

package body status is
    function status_to_unsigned(s: status_t) return unsigned is
        variable resp: unsigned(7 downto 0);
    begin
        resp := s.interrupt & s.bit_copy & s.half_carry & s.sign & s.overflow & s.negative & s.zero & s.carry;
        return resp;
    end function;

    function unsigned_to_status(u: unsigned) return status_t is
        variable resp: status_t;
    begin
        resp.carry := u(0);
        resp.zero := u(1);
        resp.negative := u(2);
        resp.overflow := u(3);
        resp.sign := u(4);
        resp.half_carry := u(5);
        resp.bit_copy := u(6);
        resp.interrupt := u(7);
        return resp;
    end function;
end package body;
