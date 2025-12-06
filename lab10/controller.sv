module controller(input  logic       clk,
                  input  logic       reset,  
                  input  logic [6:0] op,
                  input  logic [2:0] funct3,
                  input  logic       funct7b5,
                  input  logic       zero,


                  output logic [1:0] ImmSrc,
                  output logic [1:0] ALUSrcA, ALUSrcB,
                  output logic [1:0] ResultSrc, 
                  output logic       AdrSrc,
                  output logic [2:0] ALUControl,
                  output logic       IRWrite, PCWrite, 
                  output logic       RegWrite, MemWrite);

    logic PCUpdate, Branch;
    logic [1:0] ALUOp;
    logic PCWrite_fsm;

    maindec main_fsm (
        .clk(clk),
        .reset(reset),
        .op(op),
        .PCUpdate(PCUpdate), 
        .PCWrite(PCWrite_fsm),
        .Branch(Branch), 
        .RegWrite(RegWrite),
        .MemWrite(MemWrite), 
        .IRWrite(IRWrite), 
        .ResultSrc(ResultSrc), 
        .ALUSrcB(ALUSrcB), 
        .ALUSrcA(ALUSrcA), 
        .AdrSrc(AdrSrc), 
        .ALUOp(ALUOp)
    );

    aludec ad(
            .opb5(op[5]),
            .funct3(funct3),
            .funct7b5(funct7b5),
            .ALUOp(ALUOp),
            .ALUControl(ALUControl)
        );


    instrdec id(
        .op(op),
        .ImmSrc(ImmSrc)
    );

    assign PCWrite = PCWrite_fsm | (Branch & zero) | PCUpdate;  

endmodule
