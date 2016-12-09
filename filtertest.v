`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:58:11 12/06/2016
// Design Name:   Filter
// Module Name:   /home/ajermaky/Development/Homework/ECE111/Project/filtertest.v
// Project Name:  Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Filter
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module filtertest;

	// Inputs
	reg clk;
	reg rst;
	reg [31:0] x;
	reg start;

	// Outputs
	wire valid;
	wire ready;
	wire [31:0] y;

	// Instantiate the Unit Under Test (UUT)
	Filter uut (
		.clk(clk), 
		.rst(rst), 
		.x(x), 
		.start(start), 
		.valid(valid), 
		.ready(ready), 
		.y(y)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		x = 32'h3fc9a48e;
		start = 0;

		// Wait 100 ns for global reset to finish
		#100;
		rst = 1;
      #100;
      rst = 0;
		#100;
		start=1;
		#200;
		start=0;

        
		// Add stimulus here

	end
   always begin 
		#50
		clk=~clk;		
	end
endmodule

