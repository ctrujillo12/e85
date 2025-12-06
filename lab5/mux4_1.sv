module mux4_1_p #(
    parameter int P_A = 32'd37796, // A
    parameter int P_G = 32'd33673, // G
    parameter int P_E = 32'd28312, // E
    parameter int P_C = 32'd22471  // C
)(
    input  logic [1:0] s,
    input  logic       valid,
    output logic [31:0] p
);
    assign p = valid ?
                  (s[1] ? (s[0] ? P_C : P_E)
                        : (s[0] ? P_G : P_A))
                : 32'd0; // if no key pressed, output 0
endmodule
