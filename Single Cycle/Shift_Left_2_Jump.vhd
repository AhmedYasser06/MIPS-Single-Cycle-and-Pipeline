library ieee;
use ieee.std_logic_1164.all;

entity JumpShiftLeft2 is
    port(
        jump_instr : in  std_logic_vector(25 downto 0);  -- instruction[25:0]
        jump_addr  : out std_logic_vector(27 downto 0)   -- shifted left by 2
    );
end entity JumpShiftLeft2;

architecture RTL of JumpShiftLeft2 is
begin
    -- Shift left by 2 (append "00")
    jump_addr <= jump_instr & "00";
end architecture RTL;
