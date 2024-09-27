clear all;
%--------------------------------------
% Parameters to calculate Pwr
linear_scale_factor = 1;  % keep at 1  
A2Dbits = 16;  % number of bits in our A/D
MAX_ATOD_VALUE = 2^(A2Dbits-1)-1; % max possible value out of A/D assuming signed data (1 bit used for sign)
ATOD_PEAK_VOLTS = 1;  % max value in A/D maps to 1 volt
RF_impedance_ohms = 50; % RF front end impedance

%--------------------------------------
% Signal Parameters
fs = 128e3;
sig_length = 2^16; 
tx=0:1/fs:(sig_length-1)/fs;

%--------------------------------------
% High Freq Signals
%x = randn(sig_length,1) + 1i*randn(sig_length,1);
%x = x*0.5;
f_hz = 10e3;
xh1 = 0.1*exp(2*pi*1i*tx*f_hz);
f_hz = 20e3;
xh2 = 0.1*exp(2*pi*1i*tx*f_hz);
f_hz = 15e3;
xh3 = 0.1*exp(2*pi*1i*tx*f_hz);

x = xh1 + xh2 + xh3;
%x = x;
x_ampl = real(x) + imag(x);
figure(1);
%plot(real(x));
%digital_gain = 10e3;
%x = x*digital_gain;

%--------------------------------------
% 5K Signal
f_hz = 250; 
x1 = exp(2*pi*1i*tx*f_hz );
%plot(abs(x1(1:100)));


%--------------------------------------
% 5K Signal with noise

xn = x1 + x; 
%plot(tx,real(xn));

%--------------------------------------
% Normalization and Interleave int16
max_xn_abs = max(abs(xn));

xn_norm = (xn/max_xn_abs)*MAX_ATOD_VALUE;

tmp = round(xn_norm);
interlv_sig = zeros(length(tmp)*2,1);
interlv_sig(1:2:length(tmp)*2) = real(tmp);
interlv_sig(2:2:length(tmp)*2+1) = imag(tmp);
interlv_sig = int16(interlv_sig);

plot(interlv_sig(1:2:end-1));

fd = fopen('data.txt','w');
for i=1:length(interlv_sig)
    fprintf(fd, '%d\n', interlv_sig(i));
end
fclose(fd);  
