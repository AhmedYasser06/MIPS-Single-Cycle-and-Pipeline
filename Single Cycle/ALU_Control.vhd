library ieee;
use ieee.std_logic_1164.all;

entity ALUControl is
    port (
        ALUOp   : in  std_logic_vector(1 downto 0);
        Funct   : in  std_logic_vector(5 downto 0);
        control : out std_logic_vector(2 downto 0)
    );
end entity;

architecture RTL of ALUControl is
begin

    process(ALUOp, Funct)
    begin
        -- Default: ADD
        control <= "010";

        case ALUOp is

            -- ================= LW / SW =================
            when "00" =>
                control <= "010";   -- ADD

            -- ================= BEQ =================
            when "01" =>
                control <= "110";   -- SUB

            -- ================= R-Type =================
            when "10" =>
                case Funct is
                    when "100000" => control <= "010"; -- ADD
                    when "100010" => control <= "110"; -- SUB
                    when "100100" => control <= "000"; -- AND
                    when "100101" => control <= "001"; -- OR
                    when "000000" => control <= "111"; -- SLL
                    when others   => control <= "010"; -- Default ADD
                end case;

            when others =>
                control <= "010";   -- Default ADD
        end case;
    end process;

end architecture RTL;
