function signal_out = phase_randomized_surrogate(signal_in)
% When checking the validity, recall that periodogram needs the number of
% datapoints to avoid zero padding.

transpose = 0;
if size(signal_in,2)>size(signal_in,1)
    signal_in = signal_in';
    transpose = 1;
end
N = length(signal_in);
Nhalf = round(N/2);
pre_surrogate = fft(signal_in,N);
rand_phases = rand(Nhalf-1,1)*2*pi;
pre_surrogate(2:Nhalf) = pre_surrogate(2:Nhalf).*exp(1i*rand_phases);
if mod(N,2) ~= 0
    pre_surrogate(Nhalf+1:end) = pre_surrogate(Nhalf+1:end).*exp(-1i*flipud(rand_phases));
else
    pre_surrogate(Nhalf+2:end) = pre_surrogate(Nhalf+2:end).*exp(-1i*flipud(rand_phases));
end
signal_out=ifft(pre_surrogate,N);

if transpose
    signal_out = signal_out';
end
end