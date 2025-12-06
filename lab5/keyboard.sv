module keyboard(
    input  logic clk,
    input  logic reset,    // active-low reset
    input  logic [3:0] keys,
    output logic speaker
);

    // 1. Synchronizer
    logic [3:0] keys_sync;
    always_ff @(posedge clk) begin
        keys_sync <= keys;
    end

    // 2. Priority encoder
    logic [1:0] sel;
    logic valid;
    priority_enc prio (
        .keys(keys_sync),
        .sel(sel),
        .valid(valid)
    );

    // 3. Mux picks the p value
    logic [31:0] selected_p;
    mux4_1_p note_mux (
        .s(sel),
        .valid(valid),
        .p(selected_p)
    );

    // 4. Up counter
    upctr #(.width(32)) note_ctr (
        .clk(clk),
        .reset(~reset),   // module uses active-low reset
        .p(selected_p),   // feed p from mux
        .tone(speaker)
    );

endmodule

