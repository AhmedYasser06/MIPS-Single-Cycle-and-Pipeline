library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ShiftLeft2 is
    port(
        addr_in  : in  std_logic_vector(31 downto 0);
        addr_out : out std_logic_vector(31 downto 0)
    );
end entity ShiftLeft2;

architecture RTL of ShiftLeft2 is
begin
    -- Shift left by 2 bits
    addr_out <= std_logic_vector(unsigned(addr_in) sll 2);
end architecture RTL;
