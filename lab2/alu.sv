// structural Verilog code for ALU Decoder
module alu(input  logic a1, a2, b1, b2, b3, c1, c2,
  		       output logic x, y, z);
	
   
    logic n1, n2, n3, n4;
	

	 // x logic (msb)
	 and g1(x, a1, ~a2, ~b1, b2, ~b3);
	 
	 // y logic (middle bit)
	 and g2(y, a1, ~a2, b1, b2);
	 
	 // z logic (lsb)
	 and g3(n1, ~a1, a2);
	 and g4(n2, a1, ~a2, ~b1, ~b2, ~b3, c1, c2);
	 and g5(n3, a1, ~a2, ~b1, b2, ~b3);
	 and g6(n4, a1, ~a2, b1, b2, ~b3);
	 
	 or g7(z, n1, n2, n3, n4);
	 
endmodule
