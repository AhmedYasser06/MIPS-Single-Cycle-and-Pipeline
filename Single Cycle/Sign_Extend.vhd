library ieee;
use ieee.std_logic_1164.all;

entity SignExt is
    port(
        imm_in  : in  std_logic_vector(15 downto 0);
        imm_ext : out std_logic_vector(31 downto 0)
    );
end entity SignExt;

architecture RTL of SignExt is
begin
    -- Sign extension from 16 bits to 32 bits
    imm_ext <= x"0000" & imm_in when imm_in(15) = '0' else
               x"FFFF" & imm_in;
end architecture RTL;
