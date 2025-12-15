library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
    port(
        srcA    : in  std_logic_vector(31 downto 0); -- first source operand
        srcB    : in  std_logic_vector(31 downto 0); -- second source operand
        shamt   : in  integer range 0 to 31;         -- shift amount (SLL)
        control : in  std_logic_vector(2 downto 0);  -- ALU control
        result  : out std_logic_vector(31 downto 0); -- ALU result
        zero    : out std_logic                      -- zero flag
    );
end entity;

architecture ALU_ARCH of ALU is
    signal alu_result : std_logic_vector(31 downto 0);
begin

    process(srcA, srcB, control, shamt)
    begin
        alu_result <= (others => '0');

        case control is
            when "010" =>  -- ADD
                alu_result <= std_logic_vector(unsigned(srcA) + unsigned(srcB));

            when "110" =>  -- SUB
                alu_result <= std_logic_vector(unsigned(srcA) - unsigned(srcB));

            when "000" =>  -- AND
                alu_result <= srcA and srcB;

            when "001" =>  -- OR
                alu_result <= srcA or srcB;

            when "111" =>  -- SHIFT LEFT LOGICAL (SLL)
                alu_result <= std_logic_vector(shift_left(unsigned(srcB), shamt));

            when others =>
                null;
        end case;
    end process;

    result <= alu_result;
    zero   <= '1' when alu_result = x"00000000" else '0';

end architecture;
