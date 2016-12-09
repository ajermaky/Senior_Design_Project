`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:23:49 12/03/2016 
// Design Name: 
// Module Name:    FinalProject 
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
module FinalProject(
    input clk,
    input rst,
    input in,
    input [31:0] result,
    input ready,
    input done
    );

	//accessing input
	reg [9:0] addr_in;
	wire [31:0] x;
	
	input_wave input_wave (
	  .clka(clk), // input clka
	  .addra(addr_in), // input [9 : 0] addra
	  .douta(x) // output [31 : 0] douta
	);
	//temporary RAM for filtered output.
	reg wea;
	reg [7:0] addr_filt;
	reg [31:0] filt_in;
	wire [31:0] filt_out;
	filtered_input filtered_in (
	  .clka(clk), // input clka
	  .wea(wea), // input [0 : 0] wea
	  .addra(addr_filt), // input [7 : 0] addra
	  .dina(filt_in), // input [31 : 0] dina
	  .douta(filt_out) // output [31 : 0] douta
	);
	//Adder 1;

	reg [31:0] a1;
	reg [31:0] b1;
	wire [31:0] s1;

	Adder adder1 (
	  .a(a1), // input [31 : 0] a
	  .b(b1), // input [31 : 0] b
	  .clk(clk), // input clk
	  .result(s1) // output [31 : 0] result
	);
	
	//Adder 2
	reg [31:0] a2;
	reg [31:0] b2;
	wire [31:0] s2;

	Adder total (
	  .a(a2), // input [31 : 0] a
	  .b(b2), // input [31 : 0] b
	  .clk(clk), // input clk
	  .result(s2) // output [31 : 0] result
	);
	
	//Mult 1
	reg [31:0] m1;
	reg [31:0] n1;
	wire [31:0] p1;
	Mult mult (
	  .a(m1), // input [31 : 0] a
	  .b(n1), // input [31 : 0] b
	  .clk(clk), // input clk
	  .result(p1) // output [31 : 0] result
	);
	
	reg [31:0] m2;
	reg [31:0] n2;
	wire [31:0] p2;
	Mult mult2 (
	  .a(m2), // input [31 : 0] a
	  .b(n2), // input [31 : 0] b
	  .clk(clk), // input clk
	  .result(p2) // output [31 : 0] result
	);
	
	

	
	
	
	
	
	//Setting up for filter
	reg [9:0] amount; //how many iterations filter should run for...
	reg filt_start; // start the fitler
	wire filt_ready; // is filter ready
	wire filt_valid; // is filter valid for moving on.
	wire[31:0] dfilt_in; // output for filter value.
	wire inc; // flag to tell to increment addr_in.
	
	
	//wires to connect two adders and 1 mult
	wire [31:0] fa1; 
	wire [31:0] fa2;
	wire [31:0] fb1;
	wire [31:0] fb2;
	wire [31:0] fm1;
	wire [31:0] fn1;

	reg [31:0] fp1;
	reg [31:0] fs1;
	reg [31:0] fs2;

	filter_n fil(clk,rst,addr_in,amount,x,filt_start,filt_ready,filt_valid,dfilt_in,inc,fa1,fb1,fm1,fn1,fa2,fb2,fs1,fp1,fs2);
	
	FFT_N fft_n();

	reg [1:0] mux;
	parameter MNOTHING = 2'b00;
	parameter MFILTER = 2'b01;
	parameter MFFT = 2'b10;
	
	parameter L = 1000;
	parameter N = 256;
	parameter WIN = 64;
	
	reg [4:0] state;
	parameter BEGIN= 4'b0000;
	parameter FILTER= 4'b0001;
	parameter FFT= 4'b0010;
	parameter FFTWAIT= 4'b0100;
	parameter FFTREAD= 4'b0101;
	parameter END = 4'b0011;
	
	//connect all wires. This is our mux...
	always @(*)
	begin
		case(mux)
			MNOTHING: begin
				//operators
				a1<=0;
				a2<=0;
				b1<=0;
				b2<=0;
				m1<=0;
				n1<=0;
				
				//filter
				fs1<=0;
				fs2<=0;
				fp1<=0;
			end
			MFILTER: begin
				a1<=fa1;
				a2<=fa2;
				b1<=fb1;
				b2<=fb2;
				m1<=fm1;
				n1<=fn1;
				fs1<=s1;
				fs2<=s2;
				fp1<=p1;
			end
		endcase
	end
	
	always @(posedge clk)
	begin
		
		if(rst) begin
			addr_in<=0; //set up addr_in to beginning of input
			addr_filt<=0; //adder_in start
			wea<=0; //set up filt to read only
			
			//filter specific
			filt_in<=0; //input
			filt_start<=0; //dont start
			amount<=0; //iterations

			state<=BEGIN;
			mux<=MNOTHING;
		end
		else
		begin
			case(state) 
				BEGIN: begin
					amount<=N; //set first iteration to 256 (read in everything first)
					state<=FILTER; //set everything to filter
					mux<=MFILTER;
				end
				FILTER: begin
					if(filt_ready) begin
						filt_start<=1; //start the filter
						wea<=1; //set write to RAM
						state<=FILTER;
					end
					else if(filt_valid) begin
						state<=FFT;
						mux<=MFFT;
					end
					else begin
						filt_start<=0; // drop bit to ensure no repeat.
						addr_filt <= addr_in[7:0]; //set address
						filt_in<=dfilt_in; // set filt in to dfilt!
						if(inc) begin //increment the  address, and make sure it wraps around.
							if(addr_in ==L-1) begin
								addr_in<=0;
							end
							else begin
								addr_in <= addr_in+1;
							end
						end
					end
				end
				FFT: begin
					addr_filt<=0;
					wea<=0;
					state<=FFTWAIT;
				end
				FFTWAIT: begin
					state<=FFTREAD;
				end
				FFTREAD: begin
					$display("%h",filt_out);
					addr_filt<=addr_filt+1;
					state<=FFTWAIT;
				end
				END: begin
					
				end
			endcase
		end
	end

endmodule
