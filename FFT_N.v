`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:50:17 12/09/2016 
// Design Name: 
// Module Name:    FFT_N 
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
module FFT_N(
		input rst,
		input clk,
		input [31:0] in,
		output reg inc,
		input start,
		output reg ready,
		output reg valid,
		input [31:0] sum1,
		input [31:0] sum2,
		input [31:0] prod1,
		input [31:0] prod2,
		output reg [31:0] a1,
		output reg [31:0] a2,
		output reg [31:0] b1,
		output reg [31:0] b2,
		output reg [31:0] m1,
		output reg [31:0] m2,
		output reg [31:0] n1,
		output reg [31:0] n2
	);
	// for (s = 1; s<=N/2; s*=2;)
	//		r = N/s;
	//		for(k = 0; k<N;k +=s*2)
	//			for(j = 0; j<s;j++)
	//				butterfly(k+j, k+j+s, j*r)
	//			end
	//		end
	//	end
	parameter N = 255;
	reg [4:0] state;
	reg [31:0] realFFT[0:N];
	reg [31:0] imagFFT[0:N];
	integer i;
	
	reg [7:0] iter;
	reg [7:0] reversal;
	
	reg [8:0] k;
	
	reg [7:0] j;

	reg [2:0] counter;
	
	
	reg [31:0] r1,r2,i1,i2,fsum1,fsum2,fprod1,fprod2;
	wire [31:0] fa1,fa2,fb1,fb2,fm1,fm2,fn1,fn2,newr1,newr2,newi1,newi2;
	reg [6:0] r;
	reg [7:0] rdelta;
	reg [7:0] stride;
	reg fft_start;
	wire fft_valid,fft_ready;
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
	.sum1(fsum1), 
	.sum2(fsum2), 
	.a1(fa1), 
	.b1(fb1), 
	.a2(fa2), 
	.b2(fb2),
	.m1(fm1),
	.m2(fm2),
	.n1(fn1),
	.n2(fn2),
	.prod1(fprod1),
	.prod2(fprod2),
	.r(r),
	.start(fft_start), 
	.valid(fft_valid), 
	.ready(fft_ready)
	);

	parameter READY = 5'b00000;
	parameter SEEDCACHE = 5'b00001;
	parameter FFT = 5'b00010;
	parameter FFTOUTERLOOP = 5'b00011;
	parameter FFTINNERLOOP = 5'b00100;
	parameter FFT2LOOP = 5'b00101;
	parameter FFT2 = 5'b00110;
	parameter FFT2WAIT = 5'b00111;
	parameter FFTINNERLOOPEND = 5'b01000;
	parameter FFTOUTERLOOPEND = 5'b01001;
	parameter PREPMAX = 5'b01010;
	parameter MAX = 5'b01011;
	parameter ADD = 5'b01100;
	parameter OUTPUT = 5'b01101;
	parameter END= 5'b01110;
	
	parameter MFFT =0;
	parameter MEND = 1;
	
	reg mux;
	reg [31:0] ta1,tb1,tm1,tn1;
	always @(*)
	begin
		case(mux)
			MFFT:
			begin
				a1<=fa1;
				a2<=fa2;
				b1<=fb1;
				b2<=fb2;
				m1<=fm1;
				m2<=fm2;
				n1<=fn1;
				n2<=fn2;
				fprod1<=prod1;
				fprod2<=prod2;
				fsum1<=sum1;
				fsum2<=sum2;
			end
			MEND:
			begin
				a1<=ta1;
				b1<=tb1;
				m1<=tm1;
				n1<=tn1;
			end
		endcase
			
	end
	
	always @(posedge clk)
	begin
		counter<=counter+1;
		if(rst) begin
			ready<=0;
			valid<=0;
			r1<=0;
			r2<=0;
			i1<=0;
			i2<=0;
			ta1<=0;
			tb1<=0;
			tm1<=0;
			tn1<=0;
			k<=0;
			iter<=0;
			reversal<=0;
			state<=READY;
			counter<=0;
			for(i=0;i<=N;i=i+1)
			begin
				realFFT[i] <= 0;
				imagFFT[i] <= 0;
			end
		end
		else
		begin
			case(state)
				READY: begin
					ready<=1;
					if(start) begin
						state<=SEEDCACHE;
						counter<=2;
						iter<=0;
						reversal<=0;
						ready<=0;
						mux<=0;
						valid<=0;
					end
				end
				SEEDCACHE: begin
					if(counter==2)
					begin
						realFFT[reversal]<= in;
						imagFFT[reversal]<=0;
						inc<=1;
						iter<=iter+1;
						if(iter==N)
						begin
							state<=FFT;
							mux<=0;
						end
					end
					else
					begin
						inc<=0;
						for(i=0;i<8;i=i+1)
						begin
							reversal[i] <= iter[7-i];
						end
					end
				end
				FFT:
				begin
					inc<=0;
					r<=0;
					rdelta<=128;
					stride<=1;
					state<=FFTOUTERLOOP;
					
				end
				FFTOUTERLOOP: begin
					if(stride==0)
					begin
						state<=PREPMAX;
						mux<=1;
						k<=0;
						$display("window\n");

					end
					else
					begin
						state<=FFTINNERLOOP;
						k<=0;
						
					end
				end
				FFTINNERLOOP: begin
					if(k==256)
					begin
						state<= FFTOUTERLOOPEND;
					end
					else
					begin
						state<= FFT2LOOP;
						j<=0;
						r<=0;
					end
				end
				
				FFT2LOOP:
				begin
					if(j==stride)begin
						state<=FFTINNERLOOPEND;
					end
					else begin
						if(fft_ready)
						begin
						
							fft_start<=1;
							r1<=realFFT[k+j];
							i1<=imagFFT[k+j];
							r2<=realFFT[k+j+stride];
							i2<=imagFFT[k+j+stride];
							state<=FFT2WAIT;
							counter<=0;
						end
					end
				end
				
				FFT2WAIT: begin
					
					if(counter>2)
					begin
						if(fft_valid)
						begin
							
							realFFT[k+j]<=newr1;
							imagFFT[k+j]<=newi1;
							realFFT[k+j+stride]<=newr2;
							imagFFT[k+j+stride]<=newi2;
							state<=FFT2LOOP;
							j<=j+1;
							r<=rdelta+r;
						end
					end
					else
					begin
						fft_start<=0;
					end
				end	
				
				FFTINNERLOOPEND: begin
					k<=k+(stride<<1);
					state<=FFTINNERLOOP;
				end
				FFTOUTERLOOPEND: begin
					stride<=stride<<1;
					rdelta<=rdelta>>1;
					state<=FFTOUTERLOOP;
				end
				
				PREPMAX: begin
					if(k==256) begin
						state<=END;
					end
					else
					begin
						ta1<={0,realFFT[k][30:0]};
						tb1<={1,imagFFT[k][30:0]};
						counter<=0;
						state<=MAX;
					end
				end
				
				MAX: begin
					if(counter==2)begin
						n1<=32'h3e800000;
						if(sum1[31]==1)begin //imag is larger.
							tm1<={0,a1[30:0]};
							ta1<={0,b1[30:0]};
						end
						else begin
							tm1<={0,b1[30:0]};
							ta1<={0,a1[30:0]};
						end
						state<=ADD;
						counter<=0;
					end
				end
				
				ADD: begin
					if(counter==2)
					begin
						tb1<=prod1;
						state<=OUTPUT;
						counter<=0;
					end
				end
				
				OUTPUT: begin
					if(counter==2)
					begin
						$display("%h",sum1);
						state<=PREPMAX;
						k<=k+1;
					end
				end
				
				END: begin
					valid<=1;
					state<=READY;
				end
			endcase
		end
	end
endmodule
