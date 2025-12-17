-- ============================================================================
-- MIPS Single-Cycle Processor - TOP LEVEL
-- Professional Implementation with Enhanced Debugging
-- ============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Top_Level is
    port(
        clk   : in std_logic;
        reset : in std_logic
    );
end entity Top_Level;

architecture Behavioral of Top_Level is

    -- ================= Component Declarations =================
    
    component DataMem
        port(
            clk        : in  std_logic;
            addr_in    : in  std_logic_vector(31 downto 0);
            mem_write  : in  std_logic;
            mem_read   : in  std_logic;
            write_data : in  std_logic_vector(31 downto 0);
            read_data  : out std_logic_vector(31 downto 0)
        );
    end component;

    component InstrMem
        port(
            pc_in     : in  std_logic_vector(31 downto 0);
            instr_out : out std_logic_vector(31 downto 0)
        );
    end component;

    component ProgramCounter
        port(
            clk    : in  std_logic;
            reset  : in  std_logic;
            pc_in  : in  std_logic_vector(31 downto 0);
            pc_out : out std_logic_vector(31 downto 0)
        );
    end component;

    component RegFile
        port(
            clk       : in  std_logic;
            reset     : in  std_logic;
            reg_write : in  std_logic;
            wr_addr   : in  std_logic_vector(4 downto 0);
            wr_data   : in  std_logic_vector(31 downto 0);
            rd_addr1  : in  std_logic_vector(4 downto 0);
            rd_addr2  : in  std_logic_vector(4 downto 0);
            rd_data1  : out std_logic_vector(31 downto 0);
            rd_data2  : out std_logic_vector(31 downto 0)
        );
    end component;

    component ALU
        port(
            srcA    : in  std_logic_vector(31 downto 0);
            srcB    : in  std_logic_vector(31 downto 0);
            shamt   : in  integer range 0 to 31;
            control : in  std_logic_vector(2 downto 0);
            result  : out std_logic_vector(31 downto 0);
            zero    : out std_logic
        );
    end component;

    component Add_ALU
        port(
            srcA   : in  std_logic_vector(31 downto 0);
            srcB   : in  std_logic_vector(31 downto 0);
            result : out std_logic_vector(31 downto 0)
        );
    end component;

    component ALUControl
        port(
            ALUOp   : in  std_logic_vector(1 downto 0);
            Funct   : in  std_logic_vector(5 downto 0);
            control : out std_logic_vector(2 downto 0)
        );
    end component;

    component MainControl
        port(
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
    end component;

    component Mux2x1_5bit
        port(
            in0     : in  std_logic_vector(4 downto 0);
            in1     : in  std_logic_vector(4 downto 0);
            sel     : in  std_logic;
            mux_out : out std_logic_vector(4 downto 0)
        );
    end component;

    component Mux2x1_32bit
        port(
            in0     : in  std_logic_vector(31 downto 0);
            in1     : in  std_logic_vector(31 downto 0);
            sel     : in  std_logic;
            mux_out : out std_logic_vector(31 downto 0)
        );
    end component;

    component SignExt
        port(
            imm_in  : in  std_logic_vector(15 downto 0);
            imm_ext : out std_logic_vector(31 downto 0)
        );
    end component;

    component ShiftLeft2
        port(
            addr_in  : in  std_logic_vector(31 downto 0);
            addr_out : out std_logic_vector(31 downto 0)
        );
    end component;

    component JumpShiftLeft2
        port(
            jump_instr : in  std_logic_vector(25 downto 0);
            jump_addr  : out std_logic_vector(27 downto 0)
        );
    end component;

    -- ================= Constants =================
    
    constant PC_INCREMENT : std_logic_vector(31 downto 0) := x"00000004";

    -- ================= Internal Signals =================
    
    -- Program Counter Signals
    signal PC_out           : std_logic_vector(31 downto 0);
    signal PC_in            : std_logic_vector(31 downto 0);
    signal Add1_out         : std_logic_vector(31 downto 0);  -- PC + 4
    signal Add2_out         : std_logic_vector(31 downto 0);  -- Branch target
    
    -- Instruction & Decode Signals
    signal InstructionMemOut : std_logic_vector(31 downto 0);
    signal Opcode            : std_logic_vector(5 downto 0);
    signal Rs                : std_logic_vector(4 downto 0);
    signal Rt                : std_logic_vector(4 downto 0);
    signal Rd                : std_logic_vector(4 downto 0);
    signal Shamt             : std_logic_vector(4 downto 0);
    signal Funct             : std_logic_vector(5 downto 0);
    signal Immediate         : std_logic_vector(15 downto 0);
    signal JumpAddr_Instr    : std_logic_vector(25 downto 0);
    
    -- Control Signals
    signal RegDst            : std_logic;
    signal Jump              : std_logic;
    signal Branch            : std_logic;
    signal MemRead           : std_logic;
    signal MemToReg          : std_logic;
    signal MemWrite          : std_logic;
    signal ALUSrc            : std_logic;
    signal RegWrite          : std_logic;
    signal ALUOp             : std_logic_vector(1 downto 0);
    signal ALUControlSignal  : std_logic_vector(2 downto 0);
    
    -- Register File Signals
    signal Mux1_out          : std_logic_vector(4 downto 0);   -- Write register
    signal ReadData1         : std_logic_vector(31 downto 0);
    signal ReadData2         : std_logic_vector(31 downto 0);
    signal WriteData         : std_logic_vector(31 downto 0);
    
    -- ALU Signals
    signal SignExtendOut     : std_logic_vector(31 downto 0);
    signal Mux2ToAlu         : std_logic_vector(31 downto 0);  -- ALU input B
    signal AluResult         : std_logic_vector(31 downto 0);
    signal ZeroFlag          : std_logic;
    signal shamt_int         : integer range 0 to 31;
    
    -- Memory Signals
    signal DataMemOut        : std_logic_vector(31 downto 0);
    
    -- Branch & Jump Signals
    signal ShiftLeftBranch   : std_logic_vector(31 downto 0);
    signal JumpAddress       : std_logic_vector(31 downto 0);
    signal BranchDecision    : std_logic;

begin

    -- ================= Instruction Decode =================
    
    Opcode         <= InstructionMemOut(31 downto 26);
    Rs             <= InstructionMemOut(25 downto 21);
    Rt             <= InstructionMemOut(20 downto 16);
    Rd             <= InstructionMemOut(15 downto 11);
    Shamt          <= InstructionMemOut(10 downto 6);
    Funct          <= InstructionMemOut(5 downto 0);
    Immediate      <= InstructionMemOut(15 downto 0);
    JumpAddr_Instr <= InstructionMemOut(25 downto 0);
    
    -- Convert shift amount to integer
    shamt_int <= to_integer(unsigned(Shamt));
    
    -- ================= Control Logic =================
    
    -- Branch decision: Branch AND Zero
    BranchDecision <= Branch and ZeroFlag;
    
    -- Next PC calculation
    PC_in <= JumpAddress                     when Jump = '1'           else
             Add2_out                        when BranchDecision = '1' else
             Add1_out;
    
    -- Jump address formation: {PC+4[31:28], JumpAddr[27:0]}
    JumpAddress(31 downto 28) <= Add1_out(31 downto 28);

    -- ================= Component Instantiations =================

    -- Program Counter
    PCU : ProgramCounter 
        port map(
            clk    => clk,
            reset  => reset,
            pc_in  => PC_in,
            pc_out => PC_out
        );

    -- Instruction Memory
    IM : InstrMem 
        port map(
            pc_in     => PC_out,
            instr_out => InstructionMemOut
        );

    -- PC + 4 Adder
    ADD1 : Add_ALU 
        port map(
            srcA   => PC_out,
            srcB   => PC_INCREMENT,
            result => Add1_out
        );

    -- Sign Extension Unit
    SE : SignExt 
        port map(
            imm_in  => Immediate,
            imm_ext => SignExtendOut
        );

    -- Branch Address Shift Left 2
    SLL1 : ShiftLeft2 
        port map(
            addr_in  => SignExtendOut,
            addr_out => ShiftLeftBranch
        );

    -- Branch Target Adder
    ADD2 : Add_ALU 
        port map(
            srcA   => Add1_out,
            srcB   => ShiftLeftBranch,
            result => Add2_out
        );

    -- Jump Address Shift Left 2
    SLL2 : JumpShiftLeft2 
        port map(
            jump_instr => JumpAddr_Instr,
            jump_addr  => JumpAddress(27 downto 0)
        );

    -- Main Control Unit
    CTRL : MainControl 
        port map(
            Opcode   => Opcode,
            RegDst   => RegDst,
            Jump     => Jump,
            Branch   => Branch,
            MemRead  => MemRead,
            MemtoReg => MemToReg,
            MemWrite => MemWrite,
            ALUSrc   => ALUSrc,
            RegWrite => RegWrite,
            ALUOp    => ALUOp
        );

    -- ALU Control Unit
    ALUCTRL : ALUControl 
        port map(
            ALUOp   => ALUOp,
            Funct   => Funct,
            control => ALUControlSignal
        );

    -- Write Register MUX (Rt vs Rd)
    MUX1 : Mux2x1_5bit 
        port map(
            in0     => Rt,
            in1     => Rd,
            sel     => RegDst,
            mux_out => Mux1_out
        );

    -- Register File
    REGS : RegFile 
        port map(
            clk       => clk,
            reset     => reset,
            reg_write => RegWrite,
            wr_addr   => Mux1_out,
            wr_data   => WriteData,
            rd_addr1  => Rs,
            rd_addr2  => Rt,
            rd_data1  => ReadData1,
            rd_data2  => ReadData2
        );

    -- ALU Source B MUX (Register vs Immediate)
    MUX2 : Mux2x1_32bit 
        port map(
            in0     => ReadData2,
            in1     => SignExtendOut,
            sel     => ALUSrc,
            mux_out => Mux2ToAlu
        );

    -- Main ALU
    ALU1 : ALU 
        port map(
            srcA    => ReadData1,
            srcB    => Mux2ToAlu,
            shamt   => shamt_int,
            control => ALUControlSignal,
            result  => AluResult,
            zero    => ZeroFlag
        );

    -- Data Memory
    MEM : DataMem
        port map(
            clk        => clk,
            addr_in    => AluResult,
            mem_write  => MemWrite,
            mem_read   => MemRead,
            write_data => ReadData2,
            read_data  => DataMemOut
        );

    -- Write Back MUX (ALU Result vs Memory Data)
    MUX3 : Mux2x1_32bit
        port map(
            in0     => AluResult,
            in1     => DataMemOut,
            sel     => MemToReg,
            mux_out => WriteData
        );

end architecture Behavioral;
