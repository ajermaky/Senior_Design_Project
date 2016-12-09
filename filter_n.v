`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:20:30 12/06/2016 
// Design Name: 
// Module Name:    filter_n 
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
module filter_n(
	input clk,
	input rst,
	input [9:0] addr,
	input [9:0] endAddr,
	input [31:0] din,
	input start,
	output reg ready,
	output reg valid,
	output reg [31:0] dout,
	output reg inc,
	output [31:0] a1,
	output [31:0] b1,
	output [31:0] m1,
	output [31:0] n1,
	output [31:0] a2,
	output [31:0] b2,
	input [31:0] s1,
	input [31:0] p1,
	input [31:0] s2
    );

	reg [4:0] state;
	reg fil_start;
	wire fil_valid;
	wire fil_ready;
	wire [31:0] y;
	Filter filter(clk,rst,din,fil_start,fil_valid,fil_ready,y,a1,b1,m1,n1,a2,b2,s1,p1,s2);
	reg [9:0] iter;
	parameter BEGIN = 4'b0000;
	parameter READY = 4'b0001;
	parameter START = 4'b0010;
	parameter FILT = 4'b0011;
	parameter FILTWAIT = 4'b0100;
	parameter OUTPUT = 4'b0101;
	parameter WAIT = 4'b0110;
	parameter END = 4'b0111;

   reg [2:0] counter;
	always @(posedge clk)
	begin
		counter<=counter+1;
		if(rst)
		begin
			fil_start<=0;
			ready<=0;
			valid<=0;
			dout<=32'b0;
			state<=BEGIN;
			iter<=0;
			counter<=0;
		end
		else
		begin
			case(state)
				BEGIN: begin
					state<=READY;
				end
				READY: begin
					ready<=1;
					state<=(start)?START:READY; //wait and then start
				end
				START: begin
					ready<=0;
					inc<=0;
					if(iter==endAddr) begin
						state<=END;
					end
					else if(fil_ready) begin //make sure filter isready
						state<=FILTWAIT;
						fil_start<=1;
						counter<=0;		
					end
				end
				FILTWAIT: begin
					fil_start<=0;
					if(counter==2)
					begin
						state<=FILT;
					end

				end
				FILT: begin
					if(fil_valid) begin //let filter run, and when valid, go to output
						state<=OUTPUT;
					end
				end
				OUTPUT: begin
					dout<=y;
					if(iter<endAddr-1) begin //force addr to remain at 255.
						inc<= 1;
						iter<= iter+1;
						counter<=0;
						state<=WAIT;
					end
					else
					begin
						state<=END;
					end
				end
				WAIT: begin
					inc<=0;
					if(counter==2) begin
						state<=START;
					end
				end
				END: begin
					valid<=1;
					inc<=0;
					state<=READY;
				end
			endcase		
		end
	end

endmodule
