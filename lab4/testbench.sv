module testbench(); 
  logic        clk, reset;
  logic        N,E,W,S;
  logic        win, die;
  logic [1:0]  expected;
  logic [31:0] vectornum, errors;
  logic [9:0]  testvectors[10000:0];

  // instantiate device under test
  game dut (
    .clk(clk),
    .reset(reset),
    .N(N),
    .E(E),
    .W(W),
    .S(S),
    .win(win),
    .die(die)
  );

  // generate clock
  always begin
    clk = 1; #5; clk = 0; #5; 
  end 

  // at start of test, load vectors and pulse reset
  initial begin
    $readmemb("game.tv", testvectors); 
    vectornum = 0; errors = 0; reset = 1; 
    #22; reset = 0; 
  end 

  // apply test vectors on rising edge of clk 
  always @(posedge clk) begin
    if (~reset) begin
      {N,E,W,S, expected} = testvectors[vectornum];

      // inject reset between win/die paths
      if (vectornum == 8) begin
        reset <= 1; #2; reset <= 0;
      end
    end
  end

  // check results on falling edge of clk 
  always @(negedge clk) begin
    if (~reset) begin
					
      // Compare DUT outputs with delayed expected
      if (vectornum > 0 && {win, die} !== expected) begin
        $display("Error at vector %0d: inputs = N=%b E=%b W=%b S=%b", 
          vectornum-1, N, E, W, S);
        $display("   outputs = win=%b die=%b (expected %b)", 
          win, die, expected); 
        errors = errors + 1; 
      end

      vectornum = vectornum + 1;

      if (testvectors[vectornum] === 10'bx) begin 
        $display("%d tests completed with %d errors", vectornum, errors); 
        $stop; 
      end 
    end 
  end
endmodule

