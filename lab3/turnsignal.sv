module turnsignal(
    input  logic clk,
    input  logic reset,
    input  logic left, right,
    output logic la, lb, lc, ra, rb, rc
);

    // current and next state
    logic [6:0] s, sp;

    // next state logic
    // idle transitions
    and  s0l_and(sp[1], s[0], left);   // idle -> left1
    and  s0r_and(sp[4], s[0], right);  // idle -> right1
    or   sp0_or(sp[0], (s[0] & ~(left|right)), s[3], s[6]); 
                 // stay idle if no input OR finish sequences go to idle

    // left sequence
    buf  b1(sp[2], s[1]);  // left1 -> left2
    buf  b2(sp[3], s[2]);  // left2 -> left3

    // right sequence
    buf  b3(sp[5], s[4]);  // right1 -> right2
    buf  b4(sp[6], s[5]);  // right2 -> right3

    // output logic 
    // left side
    or  o_la(la, s[1], s[2], s[3]);
    or  o_lb(lb, s[2], s[3]);
    buf b_lc(lc, s[3]);

    // right side
    or  o_ra(ra, s[4], s[5], s[6]);
    or  o_rb(rb, s[5], s[6]);
    buf b_rc(rc, s[6]);

    // state register
    flopr #(7) state_reg (.clk(clk), .reset(reset), .d(sp), .q(s));

endmodule

// generic N-bit register
module flopr #(parameter N=7) (
    input  logic clk,
    input  logic reset,
    input  logic [N-1:0] d,
    output logic [N-1:0] q
);
    always_ff @(posedge clk or posedge reset)
        if (reset) q <= 7'b0000001; // idle state
        else       q <= d;
endmodule
