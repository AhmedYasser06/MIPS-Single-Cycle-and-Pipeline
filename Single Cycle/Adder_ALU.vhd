library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Add_ALU is
    port(
        srcA    : in  std_logic_vector(31 downto 0);
        srcB       : in  std_logic_vector(31 downto 0);
        result  : out std_logic_vector(31 downto 0)

    );
end entity;

architecture RTL of Add_ALU is
begin

    process(srcA, srcB)
    begin
        
            result <= std_logic_vector(unsigned(srcA) + unsigned(srcB));
        
	  
    end process;

end architecture;
