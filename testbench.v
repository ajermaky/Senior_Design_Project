`timescale 1ns / 1ps

module ProjectTB;

	// Inputs
	reg clk;
	reg rst;
	reg in;
	
	// Outputs
	wire [31:0]result;
	wire valid;

	// Instantiate the Unit Under Test (UUT)
	FinalProject uut (
		.clk(clk), 
		.rst(rst), 
		.input(in), 
		.result(result),
		.ready(ready),
		.done(valid)
		
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;		

		// Wait 100 ns for global reset to finish
		#100;
		rst=0;
        
		// Add stimulus here

	end
	always #1 clk=~clk; 
	
	integer op1,op2,op3;
	initial
		op1 = $fopen("input.txt","r");
		op2 = $fopen("output.txt","w");

	always@(negedge clk)
		op3 = $fscanf(op1, "%d\n", captured_data); 	
		if (!$feof(op1) && ready == 1)
			begin
				in = captured_data;
			end
		else if(!$feof(op1) && valid == 1)
			$fwrite(op2,"%d\n",result);

	
	initial #400000 $stop; 
	
endmodule

