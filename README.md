# Senior Design Project
The aim of the Senior Design Project is to create an FPGA to take in a
streaming waveform and produce its Spectral Energy. 

## Initial Steps
To simplify the problem, we assumed we had a given waveform of 20HZ, 50HZ, and
150 HZ, with noise in it, and to window the data to get a real-time update of 
the Spectral Energy. We would also filter out The 20 HZ portion of our signal.
The accuracy of the project will be a comparison between the Spectral Energy
produced in Matlab versus the Spectral Energy produced on the FPGA.
The overall process is as follows:
1. Obtain Waveform
2. Filter Waveform
3. Window Data
4. Apply a Fast Fourier Transform (FFT)
5. Obtain the magnitude of the FFT

## Implementation
### Phase 1: Prototype our Algorithm In Matlab
* Update Given Matlab Files
* Output the input wave and filter coefficients into *.coe files
* Visualize the Spectral Energy

#### Matlab
We began prototyping our algorithm in Matlab, taking note on what the expected
outcome should be. We tweaked the example matlab files given to us to keep 
the overall structure the same, but using our own custom made algorithms.
Our filter matched the design of omitting 20 HZ signal. A roadblock we ran 
into was deciding how large the window should be, as well as how much overlap
should there be within concurrent windows. The trade off was to decide if we 
wanted the program to run slow at bigger window size to get a more accurate 
magnitudes or to have a faster program. We found that a window size of 256 with
75% data overlap was the fastest we could go before there was no noticeable 
difference in the spectral analysis.

#### *.coe files
We outputed our initial input wave with noise, as well as our filter.
The FIR filter turns out to be symmetrical, so only half the coeffcients
were needed.

#### Visualization
The design specified we needed 5 windows of Spectral Energy to compare with
our FPGA

### Phase 2: Implementing our FPGA
* Create a Filter Module for applying an FIR filter to the data 
* Create an FFT Module that takes in input, and outputs the Fourier Transform
    * Implement a 2-FFT Module for the base case in the FFT calculation
    * Implement an N-FFT Module that did the entire FFT
* Create a Top level Module to act as a controller

As a result of time constraints, we decided to go with the “code now, optimize
later” mentality. We felt that it was much more important to show completeness
of the module, and worry about optimizations afterwards. In addition, because 
simulations that run on our individual computers tend to be slower, we did 
whatever time optimizations without regard to area, so we could to speed up the
simulation.

#### Filter
For the filter module, we decided to use an internal 55 register
cache(since our filter was 55 units long) to store the inputs as they came in 
for use in computation later. This helped take down initial hurdle of worrying 
about loading and storing values. While this does help in speed, it does take 
up some space on the board. An optimization on this at a later time is to 
convert the registers into a RAM bus, and pipeline the FSM to minimize waiting
cycles.

#### FFT
The FFT we implemented was based off of the 2-Latex Cooley-Tukey Algorithm.
Almost all implementations will showcase a recursive solution, yet we needed
an iterative solution. As a result we created our own version and validated
it with Matlab's internal FFT function. 
```Matlab
#Assume filt_x is the filtered input
X = filt_x(1:256);
X=bitrevorder(X);
stride = 1;
while(stride<256)
   r= 128/stride;
   k=1;
   while(k<=256)
       for d = (0:1:stride-1)
           a = X(k+d);
           b = X(k+d+stride);
           X(k+d) = a + exp(-2*pi/256*(1i)*r*d)*b;
           X(k+d+stride) = a - exp(-2*pi/256*(1i)*r*d)*b;
       end
       k=k+stride*2;
   end
   stride= stride*2;
end

rX = abs(real(X));
iX = abs(imag(X));

absX = max(rX,iX)+ min(rX,iX)/4;
```

To easily implement this algorithm on the FPGA, we created a 2-FFT Module that
handles the main mathematics of the FFT, and a N-FFT Module that does the 
overarching algorithm.

##### 2-FFT
The 2-FFT module takes in the real and imaginary parts of two numbers, applies 
a 2 Fourier Transform and outputs the respective real and imaginary parts. This
opeartion creates a butterfly structure that is replicated throughout for the
N-FFT. To prevent calculation of cosine and sine functions on the FPGA, we 
created a lookup table that had precomputed values of these functions. We could
have easily only used one lookup table by exploiting the fact that sine and
cosine are out of phase by pi/2; however, since our ram only had one read
access at a time, this would hamper the cycles.

##### N-FFT
The N-FFT focused on the overall algorithm, and we created an FSM that emulated
the loops, including a pre process and post process phase similar to how one
would write Assembly code. This ends up with wasted cycles, but in return we 
gain high level clarity of the algorithm that helps us in any debugging we
needed. Again, we implemented 2 256-register caches, each to house the real
and imaginary parts of the FFT respectively. We also utilized if conditionals
for the sake of speed and clarity. As a result, we end up with a bloated FPGA.
A future optimization on this portion is to simplify the FSM to limit wasted
cycles, convert the 256-register caches into RAM and pipeline the read/write
processing, and convert if conditionals into combinational logic. If pipelined
correctly, we should not see a large difference in runtime. 

#### Top Level Module
Our Top level Module simply acted as the controller for the entire process.
By modularizing the Filter and N-FFT processes, the Top level Module 
orchestrates the communication of when to filter and when to FFT. We choose 
that each module should have start,ready, and valid bits indicating when a 
module should start, when the module is ready to start, and when the module 
has a valid output. The top level module uses this handshaking for its 
processing. In addition, it windowed the data with a size of 256 and 75%
overlap as specified. Overall it ran 5 iterations of filtering and FFT since
we needed5 windows to compare with our Matlab results. It should be noted that
all modules shared the floating point adders and multipliers as well as the 
RAMS, and the top level module was also responsible for switching access for 
each module.

### Phase 3: Comparing Data and Conclusion
* Output Data
* Compare Filter SSE
* Compare Window SSE

#### Output Data
At the end of the filtering phase and the end of obtaining the magnitude of the
spectral energy, we simply printed the data out to console and input it into 
MATLAB to evaluate the sum of square errors: in Matlab, this is a 2-norm 
squared. Graphs can be seen in the Reports folder.

#### Filter SSE
* 2.0118e-11

#### Window SSE
* Win1 SSE: 8.8507e-09
* Win2 SSE: 8.4525e-09
* Win3 SSE: 1.2749e-08
* Win4 SSE: 8.6019e-09
* Win5 SSE: 8.8437e-09

## Conclusion

Due to time constraints(FINALS!!), we had to give up some design aspects in 
order to meet the deadline. We have a fully functioning simulation that solves 
the initial problem statement within a great degree of accuracy. While we 
spent more optimizations on clock cycles to get us to our goal faster with our
“code now optimize later” mentality, we unfortunately increased our total area.
Our circuit takes too long to synthesize, and we cannot get an accurate reading
on total area used, but we are pretty certain we went way over what was 
required for the board. If we had more time, we would go through and implement 
the optimizations that we suggested earlier to decrease the total area of the
board. 