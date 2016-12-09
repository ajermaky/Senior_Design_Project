`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   00:37:25 12/08/2016
// Design Name:   FFT_2
// Module Name:   /home/ajermaky/Development/Homework/ECE111/Project/fft_test.v
// Project Name:  Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FFT_2
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module fft_test;

	// Inputs
	reg clk;
	reg rst;
	reg [31:0] r1;
	reg [31:0] i1;
	reg [31:0] r2;
	reg [31:0] i2;
	reg [31:0] sum1;
	reg [31:0] sum2;
	reg [31:0] prod1;
	reg [31:0] prod2;
	reg [6:0] r;

	reg start;

	// Outputs
	wire [31:0] newr1;
	wire [31:0] newi1;
	wire [31:0] newr2;
	wire [31:0] newi2;
	wire [31:0] a1;
	wire [31:0] b1;
	wire [31:0] a2;
	wire [31:0] b2;
	wire [31:0] m1;
	wire [31:0] m2;
	wire [31:0] n1;
	wire [31:0] n2;
	
	wire valid;
	wire ready;

	// Instantiate the Unit Under Test (UUT)
	FFT_2 uut (
		.clk(clk),
		.rst(rst), 
		.r1(r1), 
		.i1(i1), 
		.r2(r2), 
		.i2(i2), 
		.newr1(newr1), 
		.newi1(newi1), 
		.newr2(newr2), 
		.newi2(newi2), 
		.sum1(sum1), 
		.sum2(sum2), 
		.a1(a1), 
		.b1(b1), 
		.a2(a2), 
		.b2(b2),
		.m1(m1),
		.m2(m2),
		.n1(n1),
		.n2(n2),
		.prod1(prod1),
		.prod2(prod2),
		.r(r),
		.start(start), 
		.valid(valid), 
		.ready(ready)
	);
	
	reg [31:0] sa1;
	reg [31:0] sb1;
	wire [31:0] result1;

	Adder add1 (
	  .a(sa1), // input [31 : 0] a
	  .b(sb1), // input [31 : 0] b
	  .clk(clk), // input clk
	  .result(result1) // output [31 : 0] result
	);
	
	reg [31:0] sa2;
	reg [31:0] sb2;
	wire [31:0] result2;
	Adder add2 (
	  .a(sa2), // input [31 : 0] a
	  .b(sb2), // input [31 : 0] b
	  .clk(clk), // input clk
	  .result(result2) // output [31 : 0] result
	);
	
	reg [31:0] pm1;
	reg [31:0] pn1;
	wire [31:0] presult1;
	Mult mult1 (
	  .a(pm1), // input [31 : 0] a
	  .b(pn1), // input [31 : 0] b
	  .clk(clk), // input clk
	  .result(presult1) // output [31 : 0] result
	);
	
	reg [31:0] pm2;
	reg [31:0] pn2;
	wire [31:0] presult2;
	Mult mult2 (
	  .a(pm2), // input [31 : 0] a
	  .b(pn2), // input [31 : 0] b
	  .clk(clk), // input clk
	  .result(presult2) // output [31 : 0] result
	);
	
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		r1 = 32'h40400000;//3
		i1 = 32'h41200000;//10
		r2 = 32'h40a00000;//5
		i2 = 32'h40000000;//2
		r = 2;
		sum1 = 0;
		sum2 = 0;
		start = 0;
		sa1<=0;
		sa2<=0;
		sb1<=0;
		sb2<=0;
		pm1<=0;
		pm2<=0;
		pn1<=0;
		pn2<=0;

		// Wait 100 ns for global reset to finish
		#100;
      rst = 1;
		#100;
		rst = 0;
		#50;
		start = 1;
		#50;
		start = 0;
		
		// Add stimulus here

	end
	
	always begin
		sa1<=a1;
		sa2<=a2;
		sb1<=b1;
		sb2<=b2;
		
		pm1<=m1;
		pm2<=m2;
		pn1<=n1;
		pn2<=n2;
		
		sum1<=result1;
		sum2<=result2;
		
		prod1<=presult1;
		prod2<=presult2;
		
		#50;
		clk=~clk;
	end
      
endmodule

