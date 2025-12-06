module sword_fsm (
	input logic clk, reset,
	input logic getting_sword, // from room fsm
	output logic have_sword // goes into room fsm
);


	typedef enum logic {
        NO_SWORD  = 1'b0,
        HAVE_SWORD = 1'b1
    } state_t;
	 
	 state_t state, next_state;
	 
	 always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= NO_SWORD;
        else     state <= next_state;
    end
	 
	 always_comb begin
		next_state = state;
		case (state)
			NO_SWORD: if (getting_sword) next_state = HAVE_SWORD;
			HAVE_SWORD: next_state = HAVE_SWORD;
		endcase
	end
	
	always_comb begin
		have_sword = (state == HAVE_SWORD);
	end
endmodule
s