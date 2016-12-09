`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:39:52 12/06/2016
// Design Name:   FinalProject
// Module Name:   /home/ajermaky/Development/Homework/ECE111/Project/final_project_test_bench.v
// Project Name:  Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FinalProject
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module final_project_test_bench;

	// Inputs
	reg clk;
	reg rst;
	reg in;
	reg [31:0] result;
	reg ready;
	reg done;

	// Instantiate the Unit Under Test (UUT)
	FinalProject uut (
		.clk(clk), 
		.rst(rst), 
		.in(in), 
		.result(result), 
		.ready(ready), 
		.done(done)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		in = 0;
		result = 0;
		ready = 0;
		done = 0;

		// Wait 100 ns for global reset to finish
		#100;
		rst=1;
		#100;
		rst=0;
	   #100;
		// Add stimulus here

	end
	
	always begin
		#50;
		clk=~clk;
	end
      
endmodule

