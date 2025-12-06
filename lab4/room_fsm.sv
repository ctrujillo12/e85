module room_fsm (
	input logic clk, reset,
	input logic have_sword, // from sword fsm
	input logic N, E, W, S, 
	output logic getting_sword, // goes into room fsm
	output logic win, die
);


	typedef enum logic [2:0] {
        CAVE, TUNNEL, RIVER, STASH, DEN, GRAVEYARD, VAULT
    } state_t;
	 
	 state_t state, next_state;
	 
	 always_ff @(posedge clk or posedge reset) begin
        if (reset) state <= CAVE;
        else     state <= next_state;
    end
	 
	 always_comb begin
		next_state = state;
		case (state)
		
			CAVE: if (E) next_state = TUNNEL;
			
			TUNNEL: if (S) next_state = RIVER;
			
			RIVER: begin
				if (W) next_state = STASH;
				else if (E) next_state = DEN;
			end
			
			STASH: if (E) next_state = RIVER;
			
			DEN: if (have_sword) next_state = VAULT;
				  else next_state = GRAVEYARD;
			
			GRAVEYARD: next_state = GRAVEYARD;
			
			VAULT:     next_state = VAULT; 
			
			default: next_state = CAVE;
			
		endcase
	end
	
	always_comb begin
		getting_sword = (state == STASH);
		win  = (state == VAULT);
		die = (state == GRAVEYARD);
	end
endmodule

