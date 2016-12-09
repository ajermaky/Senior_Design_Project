`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:24:37 12/03/2016 
// Design Name: 
// Module Name:    Filter 
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
module Filter(
	input clk,
	input rst,
	input [31:0] x,
	input start,
	output reg valid,
	output reg ready,
	output [31:0] y,
	output reg [31:0] sum_a,
	output reg [31:0] sum_b,
	output reg [31:0] mult_a,
	output reg [31:0] mult_b,
	output reg [31:0] total_sum_a,
	output reg [31:0] total_sum_b,
	input [31:0] sum,
	input [31:0] prod,
	input [31:0] total_sum

    );


	parameter N = 54;//55 elements
	parameter C = 28;//55 elements
	reg [31:0] cache [0:N];
	reg [4:0] state;
	reg [4:0] addr;
	reg [4:0] counter;
	reg [4:0] waitcounter;
	wire [31:0] coef;
	reg [31:0] coef_temp;
	coefficients coe (
	  .clka(clk), // input clka
	  .addra(addr), // input [4 : 0] addra
	  .douta(coef) // output [31 : 0] douta
	);
	
	
	parameter BEGIN= 4'b0000;
	parameter READY= 4'b0001;
	parameter START= 4'b0010;
	parameter BEGIN_CALC= 4'b0011;
	parameter CALC= 4'b0100;
	parameter CALC_WAIT= 4'b0101;
	parameter END_CALC= 4'b0110;
	parameter END= 4'b0111;

	
	assign y = total_sum;
	
	integer i;
	always @(posedge clk)
	begin
		counter<=counter+1;

		if(rst)
		begin
			addr<=0;
			state<=BEGIN;
			valid<=0;
			ready<=0;
			counter<=0;
			for (i=0; i<N+1; i=i+1)
			begin
//					if (i+shift_amount < 80) // index guard
//						array[i] <= array[i+shift_amount];
//					else
				cache[i] <= 32'b0;
			end
		end
		else
		begin
			case(state)
				BEGIN: begin
					state<=READY;
					counter<=0;
					ready<=0;
					addr<=0;
					sum_a<=0;
					sum_b<=0;
					mult_a<=0;
					mult_b<=0;
					total_sum_a<=0;
					total_sum_b<=0;
				end
				READY: begin
					//wait for start bit
					ready<=1;
					addr<=0;

					state<=(start)?START:READY;
				end
				START: begin
					//put our new input in!
					ready<=0;
					valid<=0;
					for (i=N; i>0; i=i-1)
					begin
						cache[i] <= cache[i-1];
					end
					cache[0] <=x;
					state<=BEGIN_CALC;
					counter<=0;
				end
				BEGIN_CALC: begin
					//prep x_0 + x_54 and save a_0 to temp;
					if(counter==0)
					begin
						sum_a<=cache[0];
						sum_b<=cache[N];
						mult_a<=0;
						total_sum_a<=0;
						total_sum_b<=0;
						coef_temp <=coef;
						addr<=addr+1;
					end
					else
					begin
						state<=(counter<2)?BEGIN_CALC:CALC;					
					end
				end
				CALC: begin
					//s_n = a_n+a_(N-n)
					//c_(n-1) = b_(n-1)* s_(n-1);
					//total_(n-2) += total_(n-3)+ c_(n-2)
					total_sum_a<=total_sum;
					total_sum_b<=prod;
					
					
					mult_a<=coef_temp;
					mult_b<=sum;
					
					sum_a<=cache[addr];
					if(addr==N/2)
					begin
						sum_b<=0;
						state<=END_CALC;
						counter<=0;
					end
					else
					begin
						sum_b<=cache[N-addr];
						addr<=addr+1;
						state<=CALC_WAIT;
						counter<=0;
					end
					coef_temp<= coef;
				end
				CALC_WAIT:
				begin
					state<=(counter<1)?CALC_WAIT:CALC;
				end
				END_CALC: begin
					if(counter==2)
					begin
						total_sum_a<=total_sum;
						total_sum_b<=prod;
						mult_a<=coef_temp;
						mult_b<=sum;
					end
					else if(counter==5)
					begin
						total_sum_a<=total_sum;
						total_sum_b<=prod;
						
					end
					else if(counter==7)
					begin
						state<=END;
					end
					
				end
				END: begin
					valid<=1;
					state<=READY;
					$display("%h", y);  // formatted write to display
				end
				
			endcase
		end
	end
endmodule
