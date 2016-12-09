`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:26:42 12/08/2016
// Design Name:   FFT_N
// Module Name:   /home/ajermaky/Development/Homework/ECE111/Project/fft_N_test.v
// Project Name:  Project
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FFT_N
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module fft_N_test;

	// Inputs
	reg rst;
	reg clk;
	reg [31:0] in;
	wire inc;
	reg start;
	
	wire ready;
	wire valid;

	reg [31: 0] sum1,sum2,prod1,prod2;
	wire [31:0] a1,a2,b1,b2,m1,m2,n1,n2;
	// Instantiate the Unit Under Test (UUT)
	FFT_N uut (
		.rst(rst), 
		.clk(clk), 
		.in(in), 
		.inc(inc),
		.start(start),
		.ready(ready),
		.valid(valid),
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
		.prod2(prod2)
	);
	 
	reg [6:0] addr;
	wire [31: 0] cos;
	costable costab (
	  .clka(clk), // input clka
	  .addra(addr), // input [6 : 0] addra
	  .douta(cos) // output [31 : 0] douta
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
		rst = 0;
		clk = 0;
		addr = 0;
		addr=0;
		start=0;
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
		rst=1;
		#100;
		rst=0;
		#100;
		start=1;
		#100;
		start=0;
        
		// Add stimulus here

	end
	
	always @(posedge clk)
	begin
		if(inc)
		begin
			addr<=addr+1;
		end
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
		
		in<=cos;
		#50;
		clk=~clk;
	end
endmodule

