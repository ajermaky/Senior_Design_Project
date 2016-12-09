`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:24:54 12/03/2016 
// Design Name: 
// Module Name:    FFT_2 
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
module FFT_2(
	input clk,
	input rst,
	input [31:0] r1,
	input [31:0] i1,
	input [31:0] r2,
	input [31:0] i2,
	output reg [31:0] newr1,
	output reg [31:0] newi1,
	output reg [31:0] newr2,
	output reg [31:0] newi2,
	input [31:0] sum1,
	input [31:0] sum2,
	input [31:0] prod1,
	input [31:0] prod2,
	input [6:0] r,
	output reg [31:0] a1,
	output reg [31:0] b1,
	output reg [31:0] a2,
	output reg [31:0] b2,
	output reg [31:0] m1,
	output reg [31:0] n1,
	output reg [31:0] m2,
	output reg [31:0] n2,
	input start,
	output reg valid,
	output reg ready
	
    );
	 
	 reg [6:0] addr;
	 wire [31: 0] cos;
	 wire [31: 0] sin;
	 costable costab (
	  .clka(clk), // input clka
	  .addra(addr), // input [6 : 0] addra
	  .douta(cos) // output [31 : 0] douta
	);
	
	 sintable sintab (
	  .clka(clk), // input clka
	  .addra(addr), // input [6 : 0] addra
	  .douta(sin) // output [31 : 0] douta
	);
	 
	 reg [4:0] state;
	 
	 parameter READY = 4'b0000;
	 parameter START = 4'b0001;
	 parameter EXPWAIT = 4'b0010;
	 parameter MULT = 4'b0011;
	 parameter MULTWAIT = 4'b0100;
	 parameter MULT2 = 4'b0101;
	 parameter MULT2WAIT = 4'b0110;
	 parameter PREP = 4'b0111;
	 parameter PREPWAIT = 4'b1000;
	 parameter ADD = 4'b1001;
	 parameter ADDWAIT = 4'b1010;
	 parameter SUB = 4'b1011;
	 parameter SUBWAIT = 4'b1100;
	 parameter END = 4'b1101;
	 
	 
	 reg [2:0] counter;
	 always @(posedge clk)
	 begin
		counter<=counter+1;
		if(rst)
		begin
			state<=READY;
			counter<=0;
			valid<=0;
			ready<=0;
			a1<=0;
			a2<=0;
			b1<=0;
			b2<=0;
			m1<=0;
			n1<=0;
			m2<=0;
			n2<=0;
			newr1<=0;
			newr2<=0;
			newi1<=0;
			newi2<=0;
			addr<=0;
		end
		else
		begin
			case(state)
				READY: begin
					ready<=1;
					if(start)
					begin
						state<=START;
						valid<=0;
					end
				end
				START: begin
					ready<=0;
					addr<=r;
					state<=EXPWAIT;
				
				end
				EXPWAIT: begin
					state<=MULT;
				end
				MULT: begin //(a+bi)*(x+yi) => ax-by  +(ay+bx)i
					m1<=r2; //ax
					n1<=cos;
					m2<=r2; //ay
					n2<=sin;
					state<=MULTWAIT;
					counter<=0;
				end
				MULTWAIT: begin
				if(counter==1)
					begin
						state<=MULT2;
					end
				end
				MULT2: begin
					m1<=i2; //bx
					m2<=i2; //by
					
					a1<=prod1; //ax
					a2<=prod2; // ay
					state<=MULT2WAIT;
					counter<=0;
				
				end
				MULT2WAIT: begin
					if(counter==1)
					begin
						state<=PREP;
					end
				end
				PREP: begin
					b1<={~prod2[31],prod2[30:0]}; //ax - by
					b2<=prod1; //ay + bx
					 
					state<=PREPWAIT;
					counter<=0;	
				end
				PREPWAIT: begin
				if(counter==1)
					begin
						state<=ADD;
					end
				end
				ADD: begin
					a1<=r1;
					b1<=sum1; //ax-by
					a2<=i1;
					b2<=sum2; //ay+bx
					state<=ADDWAIT;
					counter<=0;
				end
				ADDWAIT: begin
					if(counter==1)
					begin
						state<=SUB;
					end
				end
				SUB: begin
					newr1<=sum1;
					newi1<=sum2;
					
					b1<={~b1[31],b1[30:0]};
					b2<={~b2[31],b2[30:0]};
					state<=SUBWAIT;
					counter<=0;
				end
				SUBWAIT: begin
					if(counter==1)
					begin
						state<=END;
					end
				end
				END: begin
					newr2<=sum1;
					newi2<=sum2;
					valid<=1;
					state<=READY;
				end
			endcase
		end
	 end

endmodule
