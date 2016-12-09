
%% Chirp signal generation
Fs = 500;                               % Sampling frequency
T = 1/Fs;                                 % Sample time
L = 10*Fs;                               % Length of signal
t = (0:L)*T;                              % Time vector
fo = 0; f1 = 60;   % Start at 1Hz, go up to 60Hz
data = 10*chirp(t,fo,10,f1) + 2*randn(size(t));
local_len = floor(length(t)/8)+1;
local_data = zeros(local_len,1);
local_data2 = zeros(local_len,2);

%% Bandpass filter the input signal using symmetric FIR with min zeros
Fstop1 = 5;    % First Stopband Frequency
Fpass1 = 10;    % First Passband Frequency
Fpass2 = 50;   % Second Passband Frequency
Fstop2 = 55;   % Second Stopband Frequency
Astop1 = 80;    % First Stopband Attenuation (dB)
Apass  = 3;     % Passband Ripple (dB)
Astop2 = 80;    % Second Stopband Attenuation (dB)

filt_design = fdesign.bandpass('fst1,fp1,fp2,fst2,ast1,ap,ast2', Fstop1, Fpass1, Fpass2, Fstop2, Astop1, Apass, Astop2, Fs);
filt_mdl = design(filt_design, 'equiripple','MinOrder', 'any');

fig = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(3,1,1);
dir = 1;

window_len = 0.30*local_len;

for i = 1 : 2
    
    for k = 1 : 10 : numel(data) - local_len  + 1;
                
        % Get next section of the input signals
        if (dir)
             local_data = data( k : k + local_len - 1);
             local_data2 = data( end - k - local_len + 2 : end - k + 1);
        else
             local_data = data( end - k - local_len + 2 : end - k + 1);
             local_data2 = data( k : k + local_len - 1);
        end
        
        % Plot the first signal
        subplot(3,1,1);
        plot(local_data);
        xlim([0 local_len]);
        ylim([-12 12]);
        xlabel('Time (ms)','FontSize',22,'FontWeight','Bold');
        ylabel('Magnitude','FontSize',22,'FontWeight','Bold');
        title('Chirp Signal Ramping from 0 to 60 Hz with noise','FontSize',32,'FontWeight','Bold');
        
        % Plot the second signal
        subplot(3,1,2);
        plot(local_data2,'Color',[0.8 0.01 .12],'LineWidth',2);
        xlim([0 local_len]);
        ylim([-12 12]);
        xlabel('Time (ms)','FontSize',22,'FontWeight','Bold');
        ylabel('Magnitude','FontSize',22,'FontWeight','Bold');
        title('Chirp Signal Ramping from 60 to 0 Hz with noise','FontSize',32,'FontWeight','Bold');

        % Filter data on newest data
        if (dir)
            filt_data = filt_mdl.filter(local_data(end - window_len + 1: end));
            filt_data2 = filt_mdl.filter(local_data2( 1 : window_len));
        else
            filt_data2 = filt_mdl.filter(local_data2(end - window_len + 1: end));
            filt_data = filt_mdl.filter(local_data( 1 : window_len));
        end
        NFFT = 2^nextpow2(length(filt_data));
        Y = fft(filt_data,NFFT)/length(filt_data);
        Y2 = fft(filt_data2,NFFT)/length(filt_data);        
        f = Fs/2*linspace(0,1,NFFT/2+1);
        subplot(3,1,3);
        hold off;
        plot(f,2*abs(Y(1:NFFT/2+1)),'LineWidth',2);
        hold on;
        plot(f,2*abs(Y2(1:NFFT/2+1)),'Color',[0.8 0.01 .12],'LineWidth',2);        
        xlim([-1 100]);
        ylim([-0.1 7]);
        xlabel('Frequency (Hz)','FontSize',22,'FontWeight','Bold');
        ylabel('|Y(f)|','FontSize',22,'FontWeight','Bold');
        title('Spectral Analysis w/ Bandpass from 10-50 Hz','FontSize',32,'FontWeight','Bold');
        
        pause(0.05);
        
        %Temporary sol'n
        if(~fig.isvalid)
            return;
        end        
    end
    
    dir = 1 - dir;    
end