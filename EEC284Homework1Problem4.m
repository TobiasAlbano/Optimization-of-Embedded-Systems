% Givens
T = 10;
F_s = 1000;

% Vector of sampling times
sample_times = 0:1/F_s:T-1/F_s;

% Part A

% Input wave composed of two sine waves, sampling at frequencies
% specified above
t = sample_times;
x = sin(2*pi*100*t) + 10 * sin(2*pi*75*t + pi/2);

% Plotting the input signal over time
figure;
plot(t(1:50), x(1:50));
xlabel("Seconds");
ylabel("Amplitude");
title("Input Signal in Time Domain");

% Generating Power Spectrum Vector
numSignals = length(sample_times);
[x_p, f] = pspectrum(x, F_s);

% Plotting power spectrum of the input signal
figure;
% Using 10log_10 since power (x_p) is already magnitude squared
plot(f, 10*log10(x_p));
% FFT is two-sided, I ignored the mirrored half
xlim([0, F_s/2 + 1]);
xlabel("Frequency");
ylabel("Power");
title("Power Spectrum of Input Signal");

% Part B

sigmas = [0.1, 0.7, 1.0, 2.0];
mu = 0.0;

Xs = cell(length(sigmas), 1);

% Graphing input signals
figure;

for i = 1:length(sigmas)

    sigma = sigmas(i);
    
    noise_term = sqrt(sigma) * randn(size(sample_times)) + mu;
    x_n = x + noise_term;

    Xs{i} = x_n;

    subplot(length(sigmas), 1, i);
    plot(sample_times(1:50), x_n(1:50));
    
    title(sprintf("Noisy Signal (\\sigma = %.1f)", sigma));
    xlabel("Time (S)");
    ylabel("Amplitude");

end

% Graphing power spectrums
figure;

for i = 1:length(sigmas)

    x_n = Xs{i};

    [x_p, f] = pspectrum(x_n, F_s);

    subplot(length(sigmas), 1, i);
    plot(f, 10*log10(x_p));
    xlim([0, F_s/2 + 1]);

    sigma = sigmas(i);
    title(sprintf("Noisy Signal Power Spectrum (\\sigma = %.1f)", sigma));
    xlabel("Frequency");
    ylabel("Power");

end

% Part C

Ns = cell(3, 1);

figure; hold on;

for i = 1:3
    
    n = sqrt(1.0) * randn(size(sample_times)) + mu;
    Ns{i} = n;

    [x_p, f] = pspectrum(n, F_s);

    plot(f, 10*log10(x_p));
    xlim([0, 500]);

    title("Power Spectrum of Random Signals")
    xlabel("Frequency");
    ylabel("Power");

end

hold off;

figure; hold on;

for i = 1:length(Ns)

    [PpH, F] = pwelch(Ns{i}, 128, 32, 512, F_s);

    plot(F, 10*log10(PpH));
    xlim([0, 500]);

    title("PSD");
    xlabel("Frequency");
    ylabel("Power per Hertz");

end

hold off;
