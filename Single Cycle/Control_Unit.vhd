library ieee;
use ieee.std_logic_1164.all;

entity Control is
    port ( 
        Opcode   : in  std_logic_vector(5 downto 0);

        RegDst   : out std_logic;
        Jump     : out std_logic;
        Branch   : out std_logic;
        MemRead  : out std_logic;
        MemtoReg : out std_logic;
        MemWrite : out std_logic;
        ALUSrc   : out std_logic;
        RegWrite : out std_logic;

        ALUOp    : out std_logic_vector(1 downto 0)
    );
end entity;

architecture RTL of Control is
begin

    process(Opcode)
    begin
        -- ===== Default values (NOP-safe) =====
        RegDst   <= '0';
        Jump     <= '0';
        Branch   <= '0';
        MemRead  <= '0';
        MemtoReg <= '0';
        MemWrite <= '0';
        ALUSrc   <= '0';
        RegWrite <= '0';
        ALUOp    <= "00";

        case Opcode is

            -- ================= R-Type =================
            when "000000" =>     -- add, sub, and, or, sll, ...
                RegDst   <= '1';
                RegWrite <= '1';
                ALUOp    <= "10";

            -- ================= addi =================
            when "001000" =>
                ALUSrc   <= '1';
                RegWrite <= '1';
                ALUOp    <= "00";

            -- ================= lw =================
            when "100011" =>
                ALUSrc   <= '1';
                MemtoReg <= '1';
                RegWrite <= '1';
                MemRead  <= '1';
                ALUOp    <= "00";

            -- ================= sw =================
            when "101011" =>
                ALUSrc   <= '1';
                MemWrite <= '1';
                ALUOp    <= "00";

            -- ================= beq =================
            when "000100" =>
                Branch   <= '1';
                ALUOp    <= "01";

            -- ================= jump =================
            when "000010" =>
                Jump <= '1';

            when others =>
                null;
        end case;
    end process;

end architecture;
