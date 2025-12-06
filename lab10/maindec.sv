module maindec(
    input logic clk, reset,
    input logic [6:0] op, 
    output logic PCWrite, PCUpdate, Branch, RegWrite, MemWrite, IRWrite, AdrSrc, 
    output logic [1:0] ResultSrc, 
    output logic [1:0] ALUSrcB, 
    output logic [1:0] ALUSrcA,  
    output logic [1:0] ALUOp  
);

    typedef enum logic [3:0] {
        FETCH, DECODE, MEMADDR, MEMREAD, MEMWB, MEMWRITE,
        EXECUTER, EXECUTEI, ALUWB, BEQ, JAL
    } state_t;

    // opcodes
    localparam lw     = 7'b0000011;
    localparam sw     = 7'b0100011;
    localparam r_type = 7'b0110011;
    localparam i_type = 7'b0010011;
    localparam jal_op = 7'b1101111;
    localparam beq_op = 7'b1100011;

    state_t state, next_state;

    // state register
    always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= FETCH;
        else       state <= next_state;
    end

    // next state + outputs
    always_comb begin

        PCWrite = 0;
        PCUpdate = 0;
        Branch = 0;
        RegWrite = 0;
        MemWrite = 0;
        IRWrite = 0;
        AdrSrc = 0;
        ResultSrc = 2'b00;
        ALUSrcB = 2'b00;
        ALUSrcA = 2'b00;
        ALUOp   = 2'b00;

        next_state = state;

        case (state)

            FETCH: begin
                next_state = DECODE;
                PCWrite = 1;
                IRWrite = 1;
                ALUSrcB = 2'b10;
                ResultSrc = 2'b10;
            end

            DECODE: begin
                ALUSrcB = 2'b01;
                ALUSrcA = 2'b01;

                if (op == lw || op == sw) next_state = MEMADDR;
                else if (op == r_type)   next_state = EXECUTER;
                else if (op == i_type)   next_state = EXECUTEI;
                else if (op == jal_op)   next_state = JAL;
                else if (op == beq_op)   next_state = BEQ;
            end

            MEMADDR: begin
                ALUSrcB = 2'b01; 
                ALUSrcA = 2'b10; 
                ALUOp = 2'b00; 

                if (op == lw) next_state = MEMREAD;
                else if (op == sw) next_state = MEMWRITE;
            end

            MEMREAD: begin        
                ResultSrc = 2'b00;
                AdrSrc = 1'b1; 

                next_state = MEMWB;
            end

            MEMWB: begin
                RegWrite = 1'b1; 
                ResultSrc = 2'b01; 

                next_state = FETCH;
            end

            MEMWRITE: begin
                MemWrite = 1'b1; 
                ResultSrc = 2'b00; 
                AdrSrc = 1'b1; 

                next_state = FETCH;
            end

            EXECUTER: begin 
                ALUSrcB = 2'b00; 
                ALUSrcA = 2'b10; 
                ALUOp = 2'b10; 
                
                next_state = ALUWB;
            end

            EXECUTEI: begin
                ALUSrcB = 2'b01; 
                ALUSrcA = 2'b10; 
                ALUOp = 2'b10; 

                next_state = ALUWB;
            end

            ALUWB: begin 
                next_state = FETCH;

                RegWrite = 1'b1; 
                ResultSrc = 2'b00; 
            end

            BEQ: begin
                next_state = FETCH;

                Branch = 1'b1; 
                ResultSrc = 2'b00; 
                ALUSrcB = 2'b00; 
                ALUSrcA = 2'b10; 
                ALUOp = 2'b01; 
            end

            JAL: begin
                next_state = ALUWB;

                PCUpdate = 1'b1; 
                ResultSrc = 2'b00; 
                ALUSrcB = 2'b10; 
                ALUSrcA = 2'b01; 
                ALUOp = 2'b00; 
            end

            default: next_state = FETCH;

        endcase
    end
endmodule
