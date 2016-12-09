`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:33:01 12/08/2016 
// Design Name: 
// Module Name:    WriteToFFT 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module WriteToFFT(
	input clk,
	input rst,
	input iters,
	input [7:0] inputaddr,
	input [7:0] outputaddr,
	input [31:0] inVal,
	input incInput,
	output outputVal,
	output [7:0] newOutputAddr,
	input start,
	input ready,
	input valid
    );
	
	reg [4:0] state;
	reg iter;

endmodule
