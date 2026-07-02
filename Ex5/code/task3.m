% Sampling Rate Effects on Frequency Response Analysis
clc;
clear;
close all;
diary('results/logs/Task03_output.log');

fprintf('Task 3: Sampling Rate Effects on Frequency Response\n\n');

% G2(s) = 3 / (s^3 + 5s^2 - 3s)  (from Task 1, part 2)
num_G2 = [3];
den_G2 = [1, 5, -3, 0];
G2 = tf(num_G2, den_G2);

fprintf('Continuous system: G2(s) = 3/(s^3 + 5s^2 - 3s)\n\n');

% --- Find Gain Crossover Frequency ---
% Use broad frequency range to find where |G(jw)| = 0 dB
w_range = logspace(-3, 3, 10000);
[mag, ~, w_out] = bode(G2, w_range);
mag_dB = 20*log10(squeeze(mag));

% Find the 0 dB crossing (gain crossover frequency)
cross_idx = find(mag_dB(1:end-1) >= 0 & mag_dB(2:end) < 0, 1);
if isempty(cross_idx)
    % Try rising crossing as fallback
    cross_idx = find(mag_dB(1:end-1) <= 0 & mag_dB(2:end) > 0, 1);
end

if ~isempty(cross_idx)
    % Interpolate for more accurate crossover frequency
    w1 = w_out(cross_idx);
    w2 = w_out(cross_idx + 1);
    m1 = mag_dB(cross_idx);
    m2 = mag_dB(cross_idx + 1);
    % Linear interpolation
    wc = w1 + (0 - m1) * (w2 - w1) / (m2 - m1);
else
    % Fallback: use frequency of minimum magnitude
    [~, min_idx] = min(abs(mag_dB));
    wc = w_out(min_idx);
    fprintf('Warning: No clear 0 dB crossing found. Using minimum magnitude frequency.\n');
end

f1 = wc / (2 * pi);
fprintf('Gain crossover frequency:\n');
fprintf('  wc = %.6f rad/s\n', wc);
fprintf('  f1 = %.6f Hz\n', f1);

% Also compute using margin function for comparison
[Gm_c, Pm_c, Wcg_c, Wcp_c] = margin(G2);
fprintf('\nMargin function results (continuous):\n');
fprintf('  Gain crossover freq (Wcp) = %.6f rad/s\n', Wcp_c);
fprintf('  Phase crossover freq (Wcg) = %.6f rad/s\n', Wcg_c);
fprintf('  Gain margin = %.2f dB\n', 20*log10(Gm_c));
fprintf('  Phase margin = %.2f deg\n', Pm_c);

% Use the margin function's crossover frequency if available
if ~isnan(Wcp_c) && Wcp_c > 0
    wc = Wcp_c;
    f1 = wc / (2 * pi);
    fprintf('\nUsing margin function crossover frequency: f1 = %.6f Hz\n', f1);
end

% --- Sampling Rates ---
fs_multipliers = [1, 3, 10];
num_rates = length(fs_multipliers);

% Frequency vector for Bode plots (for continuous reference)
w_bode = logspace(-2, 3, 800);

fprintf('\nDiscretization and Analysis\n');

% Store margin results for comparison
margin_results = zeros(num_rates, 4);  % [Gm_dB, Pm, Wcg, Wcp]

for i = 1:num_rates
    fs = fs_multipliers(i) * f1;     % sampling frequency in Hz
    Ts = 1 / fs;                     % sampling period in seconds
    fn = fs / 2;                     % Nyquist frequency in Hz
    wn = fn * 2 * pi;                % Nyquist frequency in rad/s

    fprintf('\n--- Case %d: f = %d * f1 (Ts = %.6f s) ---\n', i, fs_multipliers(i), Ts);
    fprintf('  Sampling frequency fs = %.6f Hz\n', fs);
    fprintf('  Nyquist frequency fn = %.6f Hz (%.6f rad/s)\n', fn, wn);

    % Discretize using ZOH method
    Gz = c2d(G2, Ts, 'zoh');
    fprintf('  Discrete transfer function Gz(z):\n');
    disp(Gz);

    % Create combined figure: Bode (top) + Nyquist (bottom)
    figure(i);

    % Bode diagram: continuous vs discrete overlay
    subplot(2, 1, 1);
    if fs_multipliers(i) <= 3
        % For low sampling rates, limit frequency to Nyquist
        w_display = logspace(-2, log10(wn * 1.2), 800);
        bode(G2, w_display);
        hold on;
        bode(Gz, w_display);
        hold off;
    else
        bode(G2, w_bode);
        hold on;
        bode(Gz, w_bode);
        hold off;
    end
    title(sprintf('Bode Diagram: f_s = %d * f_1 = %.4f Hz (T_s = %.6f s)', ...
        fs_multipliers(i), fs, Ts));
    legend('Continuous G2(s)', 'Discrete Gz(z)', 'Location', 'southwest');
    grid on;

    % Nyquist diagram (discrete)
    subplot(2, 1, 2);
    nyquist(Gz);
    title(sprintf('Nyquist Diagram: Discrete System (f_s = %d * f_1)', fs_multipliers(i)));
    grid on;

    % Save combined figure
    saveas(gcf, sprintf('results/figures/Task03_Figure_%02d.png', i));

    % Compute gain and phase margins for discrete system
    [Gm_d, Pm_d, Wcg_d, Wcp_d] = margin(Gz);

    fprintf('\n  Frequency Response Margins:\n');

    if ~isnan(Gm_d) && ~isnan(Pm_d)
        fprintf('  Gain margin (discrete) = %.2f dB\n', 20*log10(Gm_d));
        fprintf('  Phase margin (discrete) = %.2f deg\n', Pm_d);
        fprintf('  Phase crossover freq (discrete) = %.4f rad/s\n', Wcg_d);
        fprintf('  Gain crossover freq (discrete) = %.4f rad/s\n', Wcp_d);
        margin_results(i, :) = [20*log10(Gm_d), Pm_d, Wcg_d, Wcp_d];
    else
        fprintf('  Margin computation returned NaN (system may have unusual characteristics).\n');
        margin_results(i, :) = [NaN, NaN, NaN, NaN];
    end

    % Accuracy analysis: compare discrete vs continuous at crossover
    [mag_c, ph_c] = bode(G2, wc);
    [mag_d, ph_d] = bode(Gz, wc);
    fprintf('\n  Accuracy at crossover frequency wc = %.4f rad/s:\n', wc);
    fprintf('  Continuous: |G(jwc)| = %.4f (%.2f dB), phase = %.2f deg\n', ...
        squeeze(mag_c), 20*log10(squeeze(mag_c)), squeeze(ph_c));
    fprintf('  Discrete:   |Gz(e^{jwcTs})| = %.4f (%.2f dB), phase = %.2f deg\n', ...
        squeeze(mag_d), 20*log10(squeeze(mag_d)), squeeze(ph_d));
    fprintf('  Magnitude error = %.4f dB\n', ...
        abs(20*log10(squeeze(mag_c)) - 20*log10(squeeze(mag_d))));
    fprintf('  Phase error = %.4f deg\n', abs(squeeze(ph_c) - squeeze(ph_d)));
end

% --- Summary and Analysis ---
fprintf('\nSUMMARY: Sampling Rate Effects\n');
fprintf('  Sampling Rate  |  Ts (s)  |  Gain Margin (dB) | Phase Margin (deg)\n');
fprintf('----------------+----------+-------------------+--------------------\n');
fprintf('  Continuous     |   N/A    |      %.2f        |      %.2f\n', ...
    20*log10(Gm_c), Pm_c);
for i = 1:num_rates
    fprintf('  f = %d * f1    |  %.6f |      %.2f        |      %.2f\n', ...
        fs_multipliers(i), 1/(fs_multipliers(i)*f1), margin_results(i, 1), margin_results(i, 2));
end
fprintf('----------------+----------+-------------------+--------------------\n');

fprintf('\nEffect Analysis:\n');
fprintf('1. At f = f1 (lowest sampling rate):\n');
fprintf('   - Sampling frequency equals crossover frequency.\n');
fprintf('   - Nyquist frequency (%.2f Hz) is below/at signal content.\n', f1/2);
fprintf('   - Significant aliasing and frequency response distortion expected.\n');
fprintf('   - Discrete system poorly matches continuous system.\n');

fprintf('\n2. At f = 3*f1:\n');
fprintf('   - Nyquist frequency (%.2f Hz) exceeds crossover frequency.\n', 3*f1/2);
fprintf('   - Basic Nyquist criterion satisfied.\n');
fprintf('   - Moderate accuracy improvement over f = f1 case.\n');

fprintf('\n3. At f = 10*f1:\n');
fprintf('   - High sampling rate provides good approximation.\n');
fprintf('   - Frequency response closely matches continuous system up to high frequencies.\n');
fprintf('   - Phase lag from ZOH discretization is minimal in the frequency range of interest.\n');

fprintf('\nConclusion:\n');
fprintf('Higher sampling rates yield more accurate frequency response matching.\n');
fprintf('A sampling rate of at least 10 times the crossover frequency is recommended\n');
fprintf('for accurate digital control system implementation.\n');

fprintf('\nTask 3 completed successfully.\n');
diary off;
