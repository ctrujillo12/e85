// top level file
module game (
	input logic clk, reset,
	input logic N, E, W, S,
	output logic win,
	output logic die
);

	// wires between room and sword fsms
	logic getting_sword;
	logic have_sword;
	
	sword_fsm sword_i (
		.clk(clk),
		.reset(reset),
		.getting_sword(getting_sword),
		.have_sword(have_sword)
	);
	
	room_fsm room_i (
		.clk(clk),
		.reset(reset),
		.have_sword(have_sword),
		.N(N),
		.E(E),
		.W(W),
		.S(S),
		.getting_sword(getting_sword),
		.win(win),
		.die(die)
	);
	
endmodule
