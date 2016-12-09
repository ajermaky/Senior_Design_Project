Fs = 500;                                  % Sampling frequency
T = 1/Fs;                                    % Sample time
L = 1000;                                   % Length of signal
t = (0:L-1)*T;                             % Time vector


fig = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(3,1,1);

%% Input signal consisting of a 20 Hz, 50 Hz and 120 Hz sine wave
x = 2*sin(2*pi*20*t) + 3*sin(2*pi*50*t) + 5*sin(2*pi*120*t); 
coefile = fopen('input.coe','wt');
coe = num2hex(single(y));
fprintf(coefile,'memory_initialization_radix=16;\n');
fprintf(coefile,'memory_initialization_vector=\n');
for i=1:(length(y))
        for j=1:8
            fprintf(coefile,'%c',coe(i,j));
        end
        
        if(i==length(y))
            fprintf(coefile,';\n');
        else
            fprintf(coefile, ',\n');
        end
end
%% Plot of input signal
subplot(4,1,1);
plot(Fs*t,x,'LineWidth',2);
xlabel('Time (ms)','FontSize',22,'FontWeight','Bold');
ylabel('Magnitude','FontSize',22,'FontWeight','Bold');
title('Input Signal Consisting of a 20Hz, 50 Hz, and 120 Hz sine wave','FontSize',32,'FontWeight','Bold');

%% Input signal with some random noise and DC offset
y = x + 2*randn(size(t)) + 0.5;
subplot(4,1,2);
plot(Fs*t,y,'LineWidth',2);
xlabel('Time (ms)','FontSize',22,'FontWeight','Bold');
ylabel('Magnitude','FontSize',22,'FontWeight','Bold');
title('Input Signal with Added Noise','FontSize',32,'FontWeight','Bold');

%% Bandpass filter the input signal using symmetric FIR with min zeros
Fstop1 = 1;    % First Stopband Frequency
Fpass1 = 35;    % First Passband Frequency
Fpass2 = 150;   % Second Passband Frequency
Fstop2 = 170;   % Second Stopband Frequency
Astop1 = 60;    % First Stopband Attenuation (dB)
Apass  = 1;     % Passband Ripple (dB)
Astop2 = 60;    % Second Stopband Attenuation (dB)

filt_design = fdesign.bandpass('fst1,fp1,fp2,fst2,ast1,ap,ast2', Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass, Astop2, Fs);
filt_mdl = design(filt_design, 'equiripple', 'FilterStructure', 'dfsymfir','MinOrder', 'any');
filt_x = filt_mdl.filter(y);%%;
coefficients = filt_mdl.Numerator;
%plot(coefficients(1:length(coefficients)/2));

%% output variables to file
coe = num2hex(single(coefficients(1:(length(coefficients)/2)+1)));

coefile = fopen('coefficients.coe','wt');

fprintf(coefile,'memory_initialization_radix=16;\n');
fprintf(coefile,'memory_initialization_vector=\n');
for i=1:(length(coefficients)/2)+1
        for j=1:8
            fprintf(coefile,'%c',coe(i,j));
        end
        
        if(i==int8((length(coefficients)/2)+1)-1)
            fprintf(coefile,';\n');
        else
            fprintf(coefile, ',\n');
        end
end

%% Window the filtered data using blackman window
% win_mdl = window(@blackman,L);
% win_x = win_mdl.*filt_x';

window_length = 256;
window_ratio = .2;

NFFT = 2^nextpow2(window_length);

Y = fft(filt_x(1:window_length),NFFT)/window_length;
f = Fs/2*linspace(0,1,NFFT/2+1);
figure
plot(f,2*abs(Y(1:NFFT/2+1)),'LineWidth',2);
start = window_length*window_ratio;

for i=1:4
    pause(2);
    start = (i)*start;
    Y = fft(filt_x(start:start+window_length-1),NFFT)/window_length;
    f = Fs/2*linspace(0,1,NFFT/2+1);
    plot(f,2*abs(Y(1:NFFT/2+1)),'LineWidth',2);
end


%% Obtain spectral energy of noisy input
NFFT = 2^nextpow2(L); 
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
subplot(4,1,3);
plot(f,2*abs(Y(1:NFFT/2+1)),'LineWidth',2);
xlim([-2 250]);
xlabel('Frequency (Hz)','FontSize',22,'FontWeight','Bold');
ylabel('|Y(f)|','FontSize',22,'FontWeight','Bold');
title('Spectral Analysis of Noisy Input Signal','FontSize',32,'FontWeight','Bold');

%% Obtain spectral energy of filtered input
NFFT = 2^nextpow2(L); 
Y = fft(win_x,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
subplot(4,1,4);
plot(f,2*abs(Y(1:NFFT/2+1)),'LineWidth',2);
xlim([-2 250]);
xlabel('Frequency (Hz)','FontSize',22,'FontWeight','Bold');
ylabel('|Y(f)|','FontSize',22,'FontWeight','Bold');
title('Spectral Energy Windowed and Bandpass Filtered 35-200Hz','FontSize',32,'FontWeight','Bold');



