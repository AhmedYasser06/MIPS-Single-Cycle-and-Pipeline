-- Top level

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Top_Level is
    port(
        clk   : in std_logic;
        reset : in std_logic
    );
end Top_Level;

architecture Behavioral of Top_Level is

-- ================= Components =================

component DataMem
    port(
        clk        : in std_logic;
        addr_in    : in std_logic_vector(31 downto 0);
        mem_write  : in std_logic;
        mem_read   : in std_logic;
        write_data : in std_logic_vector(31 downto 0);
        read_data  : out std_logic_vector(31 downto 0)
    );
end component;

component InstrMem
    port(
        pc_in     : in std_logic_vector(31 downto 0);
        instr_out : out std_logic_vector(31 downto 0)
    );
end component;

component ProgramCounter
    port(
        clk    : in std_logic;
        reset  : in std_logic;
        pc_in  : in std_logic_vector(31 downto 0);
        pc_out : out std_logic_vector(31 downto 0)
    );
end component;

component RegFile
    port(
        clk       : in std_logic;
        reset     : in std_logic;
        reg_write : in std_logic;
        wr_addr   : in std_logic_vector(4 downto 0);
        wr_data   : in std_logic_vector(31 downto 0);
        rd_addr1  : in std_logic_vector(4 downto 0);
        rd_addr2  : in std_logic_vector(4 downto 0);
        rd_data1  : out std_logic_vector(31 downto 0);
        rd_data2  : out std_logic_vector(31 downto 0)
    );
end component;

component ALU
    port(
        srcA    : in std_logic_vector(31 downto 0);
        srcB    : in std_logic_vector(31 downto 0);
        shamt   : in integer range 0 to 31;
        control : in std_logic_vector(2 downto 0);
        result  : out std_logic_vector(31 downto 0);
        zero    : out std_logic
    );
end component;

component Add_ALU
    port(
        srcA   : in std_logic_vector(31 downto 0);
        srcB   : in std_logic_vector(31 downto 0);
        result : out std_logic_vector(31 downto 0)
    );
end component;

component ALUControl
    port(
        ALUOp   : in std_logic_vector(1 downto 0);
        Funct   : in std_logic_vector(5 downto 0);
        control : out std_logic_vector(2 downto 0)
    );
end component;

component MainControl
    port(
        Opcode   : in std_logic_vector(5 downto 0);
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
end component;

component Mux2x1_5bit
    port(
        in0     : in std_logic_vector(4 downto 0);
        in1     : in std_logic_vector(4 downto 0);
        sel     : in std_logic;
        mux_out : out std_logic_vector(4 downto 0)
    );
end component;

component Mux2x1_32bit
    port(
        in0     : in std_logic_vector(31 downto 0);
        in1     : in std_logic_vector(31 downto 0);
        sel     : in std_logic;
        mux_out : out std_logic_vector(31 downto 0)
    );
end component;

component SignExt
    port(
        imm_in  : in std_logic_vector(15 downto 0);
        imm_ext : out std_logic_vector(31 downto 0)
    );
end component;

component ShiftLeft2
    port(
        addr_in  : in std_logic_vector(31 downto 0);
        addr_out : out std_logic_vector(31 downto 0)
    );
end component;

component JumpShiftLeft2
    port(
        jump_instr : in std_logic_vector(25 downto 0);
        jump_addr  : out std_logic_vector(27 downto 0)
    );
end component;

-- ================= Constants =================

constant PC_increment : std_logic_vector(31 downto 0) := x"00000004";

-- ================= Signals =================

signal PC_out, PC_in, InstructionMemOut : std_logic_vector(31 downto 0);
signal ReadData1_To_ALU, ReadData2_To_MUX2 : std_logic_vector(31 downto 0);
signal SignExtendOut, Mux2ToAlu, AluResult, Mux3_out : std_logic_vector(31 downto 0);
signal ShiftLeftToAdd2, Add1_out, Add2_out : std_logic_vector(31 downto 0);
signal JumpAddress : std_logic_vector(31 downto 0);

signal RegDst, Jump, Branch, MemRead, MemToReg, MemWrite, ALUsrc, RegWrite : std_logic;
signal ZeroCarry : std_logic;

signal Mux1_out : std_logic_vector(4 downto 0);
signal ALUControltoALU : std_logic_vector(2 downto 0);
signal ALUOp : std_logic_vector(1 downto 0);
signal shamt_int : integer range 0 to 31;

begin

-- ================= Simple Logic =================

shamt_int <= to_integer(unsigned(InstructionMemOut(10 downto 6)));

PC_in <= JumpAddress when Jump = '1'
     else Add2_out when (Branch = '1' and ZeroCarry = '1')
     else Add1_out;

JumpAddress(31 downto 28) <= Add1_out(31 downto 28);

-- ================= Instantiations =================

PCU  : ProgramCounter port map(clk, reset, PC_in, PC_out);
IM   : InstrMem       port map(PC_out, InstructionMemOut);

ADD1 : Add_ALU port map(PC_out, PC_increment, Add1_out);

SE   : SignExt port map(InstructionMemOut(15 downto 0), SignExtendOut);
SLL1 : ShiftLeft2 port map(SignExtendOut, ShiftLeftToAdd2);
ADD2 : Add_ALU port map(Add1_out, ShiftLeftToAdd2, Add2_out);

SLL2 : JumpShiftLeft2 port map(InstructionMemOut(25 downto 0), JumpAddress(27 downto 0));

CTRL : MainControl port map(
    InstructionMemOut(31 downto 26),
    RegDst, Jump, Branch, MemRead, MemToReg,
    MemWrite, ALUsrc, RegWrite, ALUOp
);

ALUCTRL : ALUControl port map(ALUOp, InstructionMemOut(5 downto 0), ALUControltoALU);

MUX1 : Mux2x1_5bit port map(
    InstructionMemOut(20 downto 16),
    InstructionMemOut(15 downto 11),
    RegDst,
    Mux1_out
);

REGS : RegFile port map(
    clk, reset, RegWrite,
    Mux1_out, Mux3_out,
    InstructionMemOut(25 downto 21),
    InstructionMemOut(20 downto 16),
    ReadData1_To_ALU, ReadData2_To_MUX2
);

MUX2 : Mux2x1_32bit port map(ReadData2_To_MUX2, SignExtendOut, ALUsrc, Mux2ToAlu);

ALU1 : ALU port map(ReadData1_To_ALU, Mux2ToAlu, shamt_int, ALUControltoALU, AluResult, ZeroCarry);

MEM  : DataMem port map(clk, AluResult, MemWrite, MemRead, ReadData2_To_MUX2, Mux3_out);

MUX3 : Mux2x1_32bit port map(AluResult, Mux3_out, MemToReg, Mux3_out);

end Behavioral;
