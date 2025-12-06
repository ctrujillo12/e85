module priority_enc (
    input  logic [3:0] keys,   // active low KEY3:0 inputs
    output logic [1:0] sel,    // 2 bits for 4 choices
    output logic       valid   // 1 if any key is pressed
);
    always_comb begin
        // default values
        sel   = 2'b00;
        valid = 1'b0;

        // highest index wins
        if (!keys[3]) begin
            sel   = 2'b11;
            valid = 1'b1;
        end else if (!keys[2]) begin
            sel   = 2'b10;
            valid = 1'b1;
        end else if (!keys[1]) begin
            sel   = 2'b01;
            valid = 1'b1;
        end else if (!keys[0]) begin
            sel   = 2'b00;
            valid = 1'b1;
        end
    end
endmodule



