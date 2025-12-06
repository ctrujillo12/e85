// self-checking test bench for ALU Decoder with a test vector file
module testbench();

    logic clk, reset;

    logic a1, a2, b1, b2, b3, c1, c2;
    logic x, y, z;

    logic xexpected, yexpected, zexpected;

    logic [31:0] vectornum, errors;

    // 7 inputs + 3 outputs = 10 bits per vector
    logic [9:0] testvectors[10000:0];

  alu dut(
        .a1(a1), .a2(a2),
        .b1(b1), .b2(b2), .b3(b3),
        .c1(c1), .c2(c2),
        .x(x), .y(y), .z(z)
    );

    always begin
        clk = 1; #5;
        clk = 0; #5;
    end

    initial begin
        // Load test vectors
        $readmemb("alu.tv", testvectors);

        vectornum = 0;
        errors    = 0;

        reset = 1; #22;
        reset = 0;
    end

   always @(posedge clk) begin
        #1; 
        {a1, a2, b1, b2, b3, c1, c2, xexpected, yexpected, zexpected}
            = testvectors[vectornum];
    end

    always @(negedge clk) if (~reset) begin
        if (x !== xexpected || y !== yexpected || z !== zexpected) begin
            $display("Error: inputs = %b",
                {a1, a2, b1, b2, b3, c1, c2});
            $display(" outputs = %b %b %b (expected %b %b %b)",
                x, y, z, xexpected, yexpected, zexpected);
            errors = errors + 1;
        end

        vectornum = vectornum + 1;

        if (testvectors[vectornum] === 10'bx) begin
            $display("%d tests completed with %d errors",
                vectornum, errors);
            $stop;
        end
    end

endmodule
