library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ProgramCounter is
    port (  
        clk    : in  std_logic;
        reset  : in  std_logic;
        pc_in  : in  std_logic_vector(31 downto 0);
        pc_out : out std_logic_vector(31 downto 0)
    );
end entity ProgramCounter;

architecture RTL of ProgramCounter is

    signal pc_reg : std_logic_vector(31 downto 0) := x"00000000";

begin

    -- ================= PC Register =================
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                pc_reg <= x"00000000";
            else
                pc_reg <= pc_in;
            end if;
        end if;
    end process;

    pc_out <= pc_reg;

end architecture RTL;
