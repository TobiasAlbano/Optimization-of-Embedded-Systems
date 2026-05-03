%% EEC 284 Assignment 3 Problem 2
% TFO Signal Analysis
% Author: Tobias Albano
% Instructions:
% - Complete all "TODO" sections
% - Do not modify function signatures
% - Submit this file with all functions completed and working
clc; clear;
%% File Path and Macros
filename = 'tfo_dataset.csv'; % (DONE) TODO: Replace with your actual file path
Fs = 8000; % Sampling frequency in Hz
SSD = [ 1.5, 3, 4.5, 7, 10 ]; % Source-to-Detector Distances
%% Load Data from D4
T = readtable(filename);
detector_data = [T.ch4Volts]';

D4 = detector_data;
%% Estimate Carrier Frequencies from D4
[f1, f2] = estimate_carrier_frequencies(detector_data, Fs);
fprintf('Estimated carrier frequencies: f1 = %.2f Hz, f2 = %.2f Hz\n', f1, f2);
%% Demodulate with I/Q Method
WL1_D4_demod = iq_demodulate(D4, f1, Fs);
WL2_D4_demod = iq_demodulate(D4, f2, Fs);
%% Down-Sample WL1 and WL2 by 100x for performance
WL1_D4_down=downsample(WL1_D4_demod',100)';
WL2_D4_down=downsample(WL2_D4_demod',100)';
%% Plot spectrogram for channel 4 wavelength λ2
plot_spectrogram(WL2_D4_down, Fs/100, 60, 0.5);
%% ----------------------------- Local Functions ----------------------------
function [f1, f2] = estimate_carrier_frequencies(signal, Fs)
% TODO: Use FFT to find two dominant carrier frequencies
% Inputs:
% signal - 1D signal from any detector
% Fs - sampling rate in Hz
% Output:
% f1 - estimated carrier frequency 1
% f2 - estimated carrier frequency 2

    n = length(signal);
    % Most values will probably be positive, but using magnitude just in
    % case
    x_f = abs(fft(signal));
    x_f = x_f(1:floor(n / 2));

    f_list = (0:n-1) * (Fs / n);
    f_list = f_list(1:floor(n / 2));

    % Removing DC (usually unnecessary)
    x_f(1:100) = 0;

    [unused, fs] = findpeaks(x_f, "SortStr", "descend", "MinPeakDistance", 50);

    f1 = f_list(fs(1));
    i = 2;
    
    while i <= length(fs)
        if abs(f_list(fs(i)) - f1) > 1.0
            f2 = f_list(fs(i));
            break;
        end
        i = i + 1;
    end


end



function demod = iq_demodulate(signal, fc, Fs)
% TODO: Perform I/Q demodulation of input signal
% Inputs:
% signal - 1D signal to demodulate
% fc - carrier frequency to demodulate
% Fs - sampling rate
% Output:
% demod - demodulated signal envelope via sqrt(I^2 + Q^2)

    Ts = (0:length(signal)-1) / Fs;

    I = signal .* cos(2*pi*fc*Ts);
    Q = signal .* sin(2*pi*fc*Ts);

    I_f = lowpass_filter(I, 15, Fs);
    Q_f = lowpass_filter(Q, 15, Fs);

    demod = sqrt(I_f.^2 + Q_f.^2);

end



function filtered = lowpass_filter(data, cutoff, Fs)
% TODO: Apply low-pass filtering for I/Q demodulation
% Inputs:
% data - 1D signal to demodulate
% cutoff - Cutoff frequency for low-pass in Hz (use 15Hz here)
% Fs - Sampling rate in Hz
% Output:
% filtered - Filtered version of input

    filtered = lowpass(data, cutoff, Fs);

end
function plot_spectrogram(signal, Fs, window_sec, overlap)
% TODO: Plot spectrogram of input 1D signal
% Requirements:
% - Frequency on x-axis, time on y-axis
% - Spectrum type: 'power'
% - X-axis limit: [0, 5] Hz
% Inputs:
% signal - A 1D signal
% Fs - Sampling frequency (e.g., 80 Hz after downsampling)
% window_sec - Window size in seconds (e.g., 60)
% overlap - Fractional overlap (e.g., 0.5)

samples = window_sec * Fs;

overlap_samples = overlap * samples;

[val, F, seconds, P] = spectrogram(signal, samples, overlap_samples, [], Fs);

Powers = 10*log10(P + 0.00000000001)';

figure;
imagesc(F, seconds, Powers);
colorbar;
xlim([0, 5]);

axis xy;
xlabel("Frequency");
ylabel("Seconds");
title("Spectogram");




end
