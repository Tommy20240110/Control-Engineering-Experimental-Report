clc; clear; close all;
diary('results/logs/Task06_output.log');

fprintf('Task 6: Non-Minimum Phase System Analysis\n\n');

s = tf('s');

%% 系统 G1: G1(s) = 6*(-s+4) / (s^2 * (0.5s+1) * (0.1s+1))
fprintf('System G1:\n');
G1 = 6 * (-s + 4) / (s^2 * (0.5*s + 1) * (0.1*s + 1));
fprintf('G1(s) = 6*(-s+4) / (s^2 * (0.5s+1) * (0.1s+1))\n');

% Find zeros and poles
z1 = zero(G1);
p1 = pole(G1);
fprintf('Zeros: ');
fprintf('%.4f ', z1);
fprintf('\n');
fprintf('Poles: ');
fprintf('%.4f ', p1);
fprintf('\n');

% Check for RHP zeros
rhp_zeros_G1 = z1(real(z1) > 0);
if ~isempty(rhp_zeros_G1)
    fprintf('RHP zeros detected at: ');
    fprintf('%.4f ', rhp_zeros_G1);
    fprintf('\n');
end

% Check for RHP poles
rhp_poles_G1 = p1(real(p1) > 0);
if ~isempty(rhp_poles_G1)
    fprintf('RHP poles detected at: ');
    fprintf('%.4f ', rhp_poles_G1);
    fprintf('\n');
end
fprintf('\n');

%% 系统 G2: G2(s) = (10s^3 - 60s^2 + 110s + 60) / (s^4 + 17s^3 + 82s^2 + 130s + 100)
fprintf('System G2:\n');
num2 = [10, -60, 110, 60];
den2 = [1, 17, 82, 130, 100];
G2 = tf(num2, den2);
fprintf('G2(s) = (10s^3 - 60s^2 + 110s + 60) / (s^4 + 17s^3 + 82s^2 + 130s + 100)\n');

% Find zeros and poles
z2 = zero(G2);
p2 = pole(G2);
fprintf('Zeros: ');
fprintf('%.4f ', z2);
fprintf('\n');
fprintf('Poles: ');
fprintf('%.4f ', p2);
fprintf('\n');

% Check for RHP zeros
rhp_zeros_G2 = z2(real(z2) > 0);
if ~isempty(rhp_zeros_G2)
    fprintf('RHP zeros detected at: ');
    fprintf('%.4f ', rhp_zeros_G2);
    fprintf('\n');
end

% Check for RHP poles
rhp_poles_G2 = p2(real(p2) > 0);
if ~isempty(rhp_poles_G2)
    fprintf('RHP poles detected at: ');
    fprintf('%.4f ', rhp_poles_G2);
    fprintf('\n');
end
fprintf('\n');

%% 频率响应分析
w = logspace(-2, 3, 3000);

% Figure 1: G1 frequency response
fprintf('Plotting G1 frequency response...\n');

% Extract data for custom plotting
[mag1, phase1] = bode(G1, w);
mag1 = squeeze(mag1);
phase1 = squeeze(phase1);
mag1_dB = 20 * log10(mag1);

figure('Name', 'Task6_G1_Frequency_Response', 'Position', [100, 100, 1000, 800]);

% Magnitude
subplot(2, 2, 1);
semilogx(w, mag1_dB, 'b', 'LineWidth', 1.5);
grid on;
xlabel('Frequency (rad/s)');
ylabel('Magnitude (dB)');
title('G1(s): Bode Magnitude');

% Phase
subplot(2, 2, 2);
semilogx(w, phase1, 'r', 'LineWidth', 1.5);
grid on;
xlabel('Frequency (rad/s)');
ylabel('Phase (deg)');
title('G1(s): Bode Phase');

% Nyquist
subplot(2, 2, [3, 4]);
[re1, im1] = nyquist(G1, w);
re1 = squeeze(re1);
im1 = squeeze(im1);
plot(re1, im1, 'b', 'LineWidth', 1.5);
hold on;
plot(-1, 0, 'r+', 'MarkerSize', 15, 'LineWidth', 2);
xlabel('Real Axis');
ylabel('Imaginary Axis');
title('G1(s): Nyquist Diagram');
grid on;
axis equal;
hold off;

saveas(gcf, 'results/figures/Task06_Figure_01.png');

% Figure 2: G2 frequency response
fprintf('Plotting G2 frequency response...\n');

[mag2, phase2] = bode(G2, w);
mag2 = squeeze(mag2);
phase2 = squeeze(phase2);
mag2_dB = 20 * log10(mag2);

figure('Name', 'Task6_G2_Frequency_Response', 'Position', [100, 100, 1000, 800]);

% Magnitude
subplot(2, 2, 1);
semilogx(w, mag2_dB, 'b', 'LineWidth', 1.5);
grid on;
xlabel('Frequency (rad/s)');
ylabel('Magnitude (dB)');
title('G2(s): Bode Magnitude');

% Phase
subplot(2, 2, 2);
semilogx(w, phase2, 'r', 'LineWidth', 1.5);
grid on;
xlabel('Frequency (rad/s)');
ylabel('Phase (deg)');
title('G2(s): Bode Phase');

% Nyquist
subplot(2, 2, [3, 4]);
[re2, im2] = nyquist(G2, w);
re2 = squeeze(re2);
im2 = squeeze(im2);
plot(re2, im2, 'b', 'LineWidth', 1.5);
hold on;
plot(-1, 0, 'r+', 'MarkerSize', 15, 'LineWidth', 2);
xlabel('Real Axis');
ylabel('Imaginary Axis');
title('G2(s): Nyquist Diagram');
grid on;
axis equal;
hold off;

saveas(gcf, 'results/figures/Task06_Figure_02.png');

%% 非最小相位行为的阶跃响应演示
figure('Name', 'Task6_Step_Response', 'Position', [100, 100, 1000, 400]);

subplot(1, 2, 1);
step(G1, 20);
grid on;
title('G1(s) Step Response');
xlabel('Time (s)');
ylabel('Output');

subplot(1, 2, 2);
step(G2, 20);
grid on;
title('G2(s) Step Response');
xlabel('Time (s)');
ylabel('Output');

saveas(gcf, 'results/figures/Task06_Figure_03.png');

%% 分析
fprintf('\nAnalysis: Why Are These Non-Minimum Phase Systems?\n');
fprintf('Definition: A system is non-minimum phase if it has zeros and/or poles in\n');
fprintf('the right-half plane (RHP), or if it contains time delays.\n\n');

fprintf('G1 analysis:\n');
if ~isempty(rhp_zeros_G1)
    fprintf('  G1 has a RHP zero at s = %.4f\n', rhp_zeros_G1(1));
    fprintf('  This is evident from the numerator term (-s+4) = -(s-4).\n');
end
fprintf('  The RHP zero causes:\n');
fprintf('    - Additional phase lag in the Bode plot (phase drops below -180 deg).\n');
fprintf('    - Initial undershoot in the step response (response goes negative first).\n');
fprintf('    - For minimum-phase systems, phase would be near %.1f deg at high frequencies,\n', -180 - 180 + 90*2);
fprintf('      but G1 shows more phase lag due to the RHP zero.\n\n');

fprintf('G2 analysis:\n');
if ~isempty(rhp_zeros_G2)
    fprintf('  G2 has RHP zeros at complex locations:\n');
    for i = 1:length(rhp_zeros_G2)
        fprintf('    s = %.4f + %.4fj\n', real(rhp_zeros_G2(i)), imag(rhp_zeros_G2(i)));
    end
end
if ~isempty(rhp_poles_G2)
    fprintf('  G2 has RHP poles, making it both non-minimum phase and unstable.\n');
else
    fprintf('  G2 has all LHP poles (stable), but RHP zeros make it non-minimum phase.\n');
end
fprintf('  The RHP complex zeros cause:\n');
fprintf('    - Unusual phase behavior in the Bode plot (more phase lag than expected).\n');
fprintf('    - Initial undershoot in the step response.\n');
fprintf('    - The phase curve drops significantly below what a minimum-phase system\n');
fprintf('      with the same magnitude response would exhibit.\n\n');

fprintf('Key characteristics of non-minimum phase systems in frequency domain:\n');
fprintf('  1. The phase lag exceeds the minimum possible for the given magnitude.\n');
fprintf('  2. The Bode phase plot shows unusual behavior (non-monotonic or excessive lag).\n');
fprintf('  3. The Nyquist plot shows unusual encirclement patterns.\n');
fprintf('  4. Step response shows initial undershoot (goes opposite to input direction).\n');

diary off;
