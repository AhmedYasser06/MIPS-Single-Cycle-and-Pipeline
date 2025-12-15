library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity InstrMem is
    port (
        pc_in     : in  std_logic_vector(31 downto 0); -- Program Counter
        instr_out : out std_logic_vector(31 downto 0)  -- Instruction output
    );
end entity InstrMem;

architecture RTL of InstrMem is

    -- 256 x 32-bit Instruction Memory
    type mem_array is array (0 to 255) of std_logic_vector(31 downto 0);

    constant instr_mem : mem_array := (

        -- ========== Initialization ==========
        0  => x"200A0007",  -- addi $t2, $zero, 7
        1  => x"200B0003",  -- addi $t3, $zero, 3

        -- ========== R-Type ALU Tests ==========
        2  => x"014B6020",  -- add  $t4, $t2, $t3  => 10
        3  => x"014B6822",  -- sub  $t5, $t2, $t3  => 4
        4  => x"014B7024",  -- and  $t6, $t2, $t3  => 3
        5  => x"014B7825",  -- or   $t7, $t2, $t3  => 7
        6  => x"000B8880",  -- sll  $s1, $t3, 2   => 12

        -- ========== Memory Access ==========
        7  => x"AD2C0004",  -- sw   $t4, 4($t1)
        8  => x"8D2D0004",  -- lw   $t5, 4($t1)

        -- ========== Branch (TAKEN) ==========
        9  => x"114B0001",  -- beq  $t2, $t3, +1 (NOT taken)
        10 => x"200E0001",  -- addi $t6, $zero, 1

        -- ========== Jump ==========
        11 => x"0800000F",  -- j    to instruction 15

        12 => x"200F0002",  -- addi $t7, $zero, 2 (skipped)
        13 => x"20100003",  -- addi $s0, $zero, 3 (skipped)

        -- ========== Program End ==========
        15 => x"00000000",  -- nop
        16 => x"00000000",  -- nop

        others => (others => '0')
    );

    signal pc_word_addr : unsigned(7 downto 0);

begin
    -- Byte-addressed PC ? word index
    pc_word_addr <= unsigned(pc_in(9 downto 2));

    instr_out <= instr_mem(to_integer(pc_word_addr));

end architecture RTL;
