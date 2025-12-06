module upctr #(parameter width= 32)(
    input  logic              clk,
    input  logic              reset,   // active-low
    input  logic [width-1:0]  p,       // phase increment
    output logic              tone
);

    logic [width-1:0] step_counter;

    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            step_counter <= 0;
            tone         <= 0;
        end else if (p == 0) begin
            step_counter <= 0;
            tone         <= 0;
        end else begin
            step_counter <= step_counter + p;
            tone         <= step_counter[width-1]; // MSB gives square wave
        end
    end

endmodule

