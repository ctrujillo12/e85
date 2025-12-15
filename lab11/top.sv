// =======================================================
//             TOP 
// =======================================================
module top(
    input  logic        clk, reset, 
    output logic [31:0] WriteData, DataAdr, 
    output logic        MemWrite
);

    logic [31:0] ReadData;

    // instantiate!
    riscvmulti RiscvMP(clk, reset, ReadData, DataAdr, WriteData, MemWrite);
    idmem    idmem(clk, MemWrite, DataAdr, WriteData, ReadData);

endmodule



// =======================================================
//            RISCV MULTI PROCESSOR
// =======================================================
module riscvmulti(
    input  logic        clk, reset,
    input  logic [31:0] ReadData,
    output logic [31:0] DataAdr, WriteData,
    output logic        MemWrite
);

    // control signals
    logic       ALUSrc, RegWrite, AdrSrc, PCWrite, IRWrite;
    logic [1:0] ResultSrc, ALUSrcA, ALUSrcB;
    logic [2:0] ALUControl, ImmSrc; // ****
    logic [31:0] Instr; // instr read from memory
    logic Zero;

    // controller
    controller c(
        clk, reset, Instr[6:0], Instr[14:12], Instr[30], Zero, 
        ImmSrc, ALUSrcA, ALUSrcB, ResultSrc, AdrSrc, ALUControl, 
        IRWrite, PCWrite, RegWrite, MemWrite
    );

    // datapath
    datapath dp(
        clk, reset, ResultSrc, PCWrite, IRWrite, ALUSrcA, ALUSrcB, AdrSrc, RegWrite,
        ImmSrc, ALUControl, Zero, Instr, DataAdr, WriteData, ReadData
    );

endmodule



// =======================================================
//           FFS
// =======================================================

// ff enable!
module flopenr #(parameter WIDTH = 8) 
(
    input logic clk, reset, en,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

    always_ff @(posedge clk or posedge reset)
        if (reset)      q <= 0;
        else if (en)    q <= d;

endmodule


// ff no enable
module flopr #(parameter WIDTH = 8)
(
    input logic clk, reset,
    input logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

    always_ff @(posedge clk or posedge reset)
        if (reset) q <= 0;
        else       q <= d;

endmodule



// =======================================================
//                    MUXS
// =======================================================

// 2 input mux
module mux2 #(parameter WIDTH = 8)
(
    input  logic [WIDTH-1:0] d0, d1,
    input  logic             s,
    output logic [WIDTH-1:0] y
);

    assign y = s ? d1 : d0;

endmodule

// 3 input mux
module mux3 #(parameter WIDTH = 8)
(
    input  logic [WIDTH-1:0] d0, d1, d2,
    input  logic [1:0]       s,
    output logic [WIDTH-1:0] y
);

    assign y = s[1] ? d2 : (s[0] ? d1 : d0);

endmodule



// =======================================================
//    REG FILE,EXTEND ,ALU, IDMEM
// =======================================================

// register file
module regfile(
    input  logic        clk, 
    input  logic        we3, 
    input  logic [4:0]  a1, a2, a3, 
    input  logic [31:0] wd3, 
    output logic [31:0] rd1, rd2
);

    logic [31:0] rf[31:0];

    // read combinationally
    assign rd1 = (a1 != 0) ? rf[a1] : 0;
    assign rd2 = (a2 != 0) ? rf[a2] : 0;

    always_ff @(posedge clk)
        if (we3) rf[a3] <= wd3;

endmodule


// imm extension
module extend(
    input  logic [31:7] instr,
    input  logic [2:0]  immsrc, // ****
    output logic [31:0] immext
);

    always_comb
        case(immsrc)
            3'b000: immext = {{20{instr[31]}}, instr[31:20]};               // I-type
            3'b001: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // S-type
            3'b010: immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
            3'b011: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; // J-type
				
	3'b100: immext = {{instr[31:12]}, 12'b0};// U-type // ****
				
            default: immext = 32'bx; // just in case
        endcase

endmodule


// ALU
module alu(
    input  logic [31:0] a, b,
    input  logic [2:0]  ALUControl,
    output logic [31:0] result,
    output logic        zero
);

    logic [31:0] condinvb, sum;
    logic sub;

    assign sub = (ALUControl[1:0] == 2'b01);
    assign condinvb = sub ? ~b : b;
    assign sum = a + condinvb + sub;

    always_comb
        case(ALUControl)
            3'b000: result = sum;       // add
            3'b001: result = sum;       // subtract
            3'b010: result = a & b;     // and
            3'b011: result = a | b;     // or
            3'b101: result = sum[31];   // slt
            default: result = 0;
        endcase

    assign zero = (result == 32'b0);

endmodule


// data/instr memory
module idmem(
    input  logic        clk, we,
    input  logic [31:0] a, wd,
    output logic [31:0] rd
);

    logic [31:0] RAM[63:0];

    initial $readmemh("memfile.dat", RAM);

    assign rd = RAM[a[31:2]]; 

    always_ff @(posedge clk)
        if (we) RAM[a[31:2]] <= wd;

endmodule



// =======================================================
//       DATAPATH
// =======================================================
module datapath(
    input  logic        clk, reset,
    input  logic [1:0]  ResultSrc,
    input  logic        PCWrite,
    input  logic        IRWrite,
    input  logic [1:0]  ALUSrcA, ALUSrcB,
    input  logic        AdrSrc,
    input  logic        RegWrite,
    input  logic [2:0]  ImmSrc, // ****
    input  logic [2:0]  ALUControl,
    output logic        Zero,
    output logic [31:0] Instr,
    output logic [31:0] DataAdr,
    output logic [31:0] WriteData,
    input  logic [31:0] ReadData
);

    logic [31:0] PCNext, PC, OldPC;
    logic [31:0] ImmExt;
    logic [31:0] A, SrcA, SrcB;
    logic [31:0] ALUResult;
    logic [31:0] ALUOut;
    logic [31:0] Result;
    logic [31:0] Data;
    logic [31:0] rd1;
    logic [31:0] rd2;

    // next PC logic
    assign PCNext = Result;
    flopenr #(32) pcreg(clk, reset, PCWrite, PCNext, PC);
    mux2 #(32) pcadd4(PC, Result, AdrSrc, DataAdr);

    // old PC reg
    flopenr #(32) oldreg(clk, reset, IRWrite, PC, OldPC);

    // instr reg
    flopenr #(32) memreg(clk, reset, IRWrite, ReadData, Instr);

    // data regi
    flopr #(32) readreg(clk, reset, ReadData, Data);

    // imm extension
    extend ext(Instr[31:7], ImmSrc, ImmExt);

    // reg file FF for rd1
    flopr #(32) rd1reg(clk, reset, rd1, A);

    // reg file FF for rd2
    flopr #(32) rd2reg(clk, reset, rd2, WriteData);

    // ALU input muxes
    mux3 #(32) srcamux(PC, OldPC, A, ALUSrcA, SrcA);
    mux3 #(32) srcbmux(WriteData, ImmExt, 32'd4, ALUSrcB, SrcB);

    // ALU
    alu aluunit(SrcA, SrcB, ALUControl, ALUResult, Zero);

    // ALU result register
    flopr #(32) alureg(clk, reset, ALUResult, ALUOut);

    // result selection mux
    mux3 #(32) resultmux(ALUOut, Data, ALUResult, ResultSrc, Result);

    regfile rf(
        .clk   (clk),
        .we3   (RegWrite),
        .a1    (Instr[19:15]),
        .a2    (Instr[24:20]),
        .a3    (Instr[11:7]),
        .wd3   (Result),
        .rd1   (rd1),
        .rd2   (rd2)
    );

endmodule



// =======================================================
//              CONTROLLER
// =======================================================
module controller( 
    input logic clk, 
    input logic reset, 
    input logic [6:0] op, 
    input logic [2:0] funct3,
    input logic funct7b5, 
    input logic Zero, 
    output logic [2:0] Immsrc, // ****
    output logic [1:0] ALUSrcA, ALUSrcB, 
    output logic [1:0] ResultSrc, 
    output logic AdrSrc, 
    output logic [2:0] ALUControl, 
    output logic IRWrite, PCWrite, 
    output logic RegWrite, MemWrite 
);

    logic [1:0] ALUOp; 
    logic PCUpdate; 
    logic Branch; 

    instrdecoder m(op, Immsrc);

    mainfsm mf(
        clk, reset, op, Branch, PCUpdate, RegWrite, MemWrite,
        IRWrite, ALUSrcA, ALUSrcB, ResultSrc, ALUOp, AdrSrc
    );

    aludecoder dec(op[5], funct3, funct7b5, ALUOp, ALUControl);

    assign PCWrite = PCUpdate | (Branch & Zero); 

endmodule



// =======================================================
//      CONTROLLER FSM
// =======================================================
module mainfsm(
    input logic clk, 
    input logic reset,
    input logic [6:0] op, 
    output logic Branch, 
    output logic PCUpdate, 
    output logic RegWrite, 
    output logic MemWrite, 
    output logic IRWrite, 
    output logic [1:0] ALUSrcA, ALUSrcB, 
    output logic [1:0] ResultSrc, 
    output logic [1:0] ALUOp, 
    output logic AdrSrc
);

    typedef enum logic [3:0] {S0,S1,S2,S3,S4,S5,S6,S7,S8,S9,S10, S11} statetype;
    statetype state, nextstate;

    always_ff @(posedge clk or posedge reset)
        if(reset) state <= S0;
        else      state <= nextstate;

    
    always_comb begin
        nextstate = state;

        case(state)
            S0: nextstate = S1;
            S1: case(op)
                    7'b0000011: nextstate = S2;  // lw
                    7'b0100011: nextstate = S2;  // sw
                    7'b0110011: nextstate = S6;  // R-type
                    7'b0010011: nextstate = S8;  // I-type ALU
                    7'b1101111: nextstate = S9;  // jal
                    7'b1100011: nextstate = S10; // beq
	        7'b0010111: nextstate = S11; // auipc  *****
                    default: nextstate = S0;
                endcase
            S2: case(op)
                    7'b0000011: nextstate = S3;  // lw
                    7'b0100011: nextstate = S5;  // sw
                    default: nextstate = S2;
                endcase
            S3: nextstate = S4;
            S4: nextstate = S0;
            S5: nextstate = S0;
            S6: nextstate = S7;
            S7: nextstate = S0;
            S8: nextstate = S7;
            S9: nextstate = S7;
            S10: nextstate = S0;
	S11: nextstate = S0;
        endcase
    end

    // output logic
    always_comb begin
        IRWrite = 0; RegWrite = 0; MemWrite = 0;
        ALUSrcB = 2'b00; ALUSrcA = 2'b00;
        AdrSrc = 0; ALUOp = 2'b00;
        Branch = 0; PCUpdate = 0; ResultSrc = 2'b00;

        case(state)
            S0: begin
                IRWrite = 1;
                PCUpdate = 1;
                AdrSrc = 0;
                ALUSrcA = 2'b00;
                ALUSrcB = 2'b10;
                ALUOp = 2'b00;
                ResultSrc = 2'b10;
            end
            S1: begin
                ALUSrcA = 2'b01;
                ALUSrcB = 2'b01;
                ALUOp = 2'b00;
            end
            S2: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b01;
                ALUOp = 2'b00;
            end
            S3: begin
                ResultSrc = 2'b00;
                AdrSrc = 1;
            end
            S4: begin
                ResultSrc = 2'b01;
                RegWrite = 1;
            end
            S5: begin
                ResultSrc = 2'b00;
                AdrSrc = 1;
                MemWrite = 1;
            end
            S6: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b00;
                ALUOp = 2'b10;
            end
            S7: begin
                ResultSrc = 2'b00;
                RegWrite = 1;
            end
            S8: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b01;
                ALUOp = 2'b10;
            end
            S9: begin
                ALUSrcA = 2'b01;
                ALUSrcB = 2'b10;
                ALUOp = 2'b00;
                ResultSrc = 2'b00;
                PCUpdate = 1;
            end
            S10: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b00;
                ALUOp = 2'b01;
                ResultSrc = 2'b00;
                Branch = 1;
            end
	S11: begin   // auipc *******
	     ALUSrcA   = 2'b01;  // OldPC
	     ALUSrcB   = 2'b01;  // ImmExt
	     ALUOp     = 2'b00;  // add
	     ResultSrc = 2'b00;  // ALUOut
	     RegWrite  = 1;      
	end
        endcase
    end

endmodule



// =======================================================
//              ALU DECODER 
// =======================================================
module aludecoder(
    input logic opb5, 
    input logic [2:0] funct3,
    input logic funct7b5,
    input logic [1:0] ALUOp,
    output logic [2:0] ALUControl
);

    always_comb begin
        case(ALUOp)
            2'b00: ALUControl = 3'b000; // lw, sw add
            2'b01: ALUControl = 3'b001; // beq subtract
            2'b10: begin
                case(funct3)
                    3'b000: begin
                        if (opb5 & funct7b5) // R-type sub
                            ALUControl = 3'b001;
                        else                 // R-type add or I-type addi
                            ALUControl = 3'b000;
                    end
                    3'b010: ALUControl = 3'b101; // slt/slti
                    3'b110: ALUControl = 3'b011; // or/ori
                    3'b111: ALUControl = 3'b010; // and/andi
                    default: ALUControl = 3'b000;
                endcase
            end
            default: ALUControl = 3'b000;
        endcase
    end

endmodule



// =======================================================
//           INSTR DEC
// =======================================================
module instrdecoder(
    input logic [6:0] op,
    output logic [2:0] ImmSrc   // ****
);

    always_comb begin
        case(op)
            7'b0010011: ImmSrc = 3'b000; // I-type ALU
            7'b0000011: ImmSrc = 3'b000; // lw
            7'b0100011: ImmSrc = 3'b001; // sw
            7'b1100011: ImmSrc = 3'b010; // beq
            7'b1101111: ImmSrc = 3'b011; // jal
	7'b0010111: ImmSrc = 3'b100; // auipc   *****
            default:     ImmSrc = 3'b000; // R-type
        endcase
    end

endmodule


