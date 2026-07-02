%% 任务4: 稳定裕度
% Example 5-21: Nyquist and Bode plots, compute phase and gain margins
% Exercise 5-22: Bode diagram and stability analysis
% Fixed: added mkdir for output directories.

clc;
clear;
close all;

% Ensure output directories exist
if ~exist('results/logs', 'dir'), mkdir('results/logs'); end
if ~exist('results/figures', 'dir'), mkdir('results/figures'); end

diary('results/logs/Task04_output.log');

fprintf('Task 4: Stability Margins\n\n');

%% 第1部分: 示例5-21 稳定裕度分析
fprintf('Part 1: Stability Margins (Example 5-21)\n\n');

% System: G(s) = 40/(s*(0.1s+1)*(0.05s+1))
num1 = [40];
den1 = conv([1, 0], conv([0.1, 1], [0.05, 1]));
G1 = tf(num1, den1);

fprintf('System: G(s) = 40/(s(0.1s+1)(0.05s+1))\n');
disp(G1);
fprintf('\n');

% Bode plot with margins
figure;
margin(G1);
title('Bode Plot of G(s) = 40/(s(0.1s+1)(0.05s+1))');
grid on;
saveas(gcf, 'results/figures/Task04_Figure_01.png');
fprintf('Figure 1 saved: Bode plot with margins.\n');

% Get margin values
[Gm1, Pm1, Wcg1, Wcp1] = margin(G1);
fprintf('Gain Margin (Gm) = %.4f (%.2f dB)\n', Gm1, 20*log10(Gm1));
fprintf('Phase Margin (Pm) = %.4f deg\n', Pm1);
fprintf('Phase crossover frequency (Wcg) = %.4f rad/s\n', Wcg1);
fprintf('Gain crossover frequency (Wcp) = %.4f rad/s\n\n', Wcp1);

% Nyquist plot
figure;
nyquist(G1);
title('Nyquist Plot of G(s) = 40/(s(0.1s+1)(0.05s+1))');
grid on;
saveas(gcf, 'results/figures/Task04_Figure_02.png');
fprintf('Figure 2 saved: Nyquist plot.\n');

% Zoomed Nyquist around critical point
figure;
nyquist(G1);
title('Nyquist Plot (Zoomed)');
axis([-3, 1, -3, 3]);
grid on;
saveas(gcf, 'results/figures/Task04_Figure_03.png');
fprintf('Figure 3 saved: Nyquist plot (zoomed).\n');

% Check stability based on margins
if Pm1 > 0 && Gm1 > 1
    fprintf('System is stable (positive gain and phase margins).\n\n');
else
    fprintf('System is unstable (negative gain or phase margin).\n\n');
end

%% 第2部分: 习题5-22 Bode图与稳定性分析
fprintf('Part 2: Stability Analysis (Exercise 5-22)\n\n');

% System: G(s) = 10/(s(s+1)(s+10))
num2 = [10];
den2 = conv([1, 0], conv([1, 1], [1, 10]));
G2 = tf(num2, den2);

fprintf('System: G(s) = 10/(s(s+1)(s+10))\n');
disp(G2);
fprintf('\n');

% Bode plot
figure;
margin(G2);
title('Bode Plot of G(s) = 10/(s(s+1)(s+10))');
grid on;
saveas(gcf, 'results/figures/Task04_Figure_04.png');
fprintf('Figure 4 saved: Bode plot with margins.\n');

% Get margin values
[Gm2, Pm2, Wcg2, Wcp2] = margin(G2);
fprintf('Gain Margin (Gm) = %.4f (%.2f dB)\n', Gm2, 20*log10(Gm2));
fprintf('Phase Margin (Pm) = %.4f deg\n', Pm2);
fprintf('Phase crossover frequency (Wcg) = %.4f rad/s\n', Wcg2);
fprintf('Gain crossover frequency (Wcp) = %.4f rad/s\n\n', Wcp2);

% Nyquist plot
figure;
nyquist(G2);
title('Nyquist Plot of G(s) = 10/(s(s+1)(s+10))');
grid on;
saveas(gcf, 'results/figures/Task04_Figure_05.png');
fprintf('Figure 5 saved: Nyquist plot.\n');

% Zoomed Nyquist around critical point
figure;
nyquist(G2);
title('Nyquist Plot of G(s) = 10/(s(s+1)(s+10)) (Zoomed)');
axis([-2, 1, -2, 2]);
grid on;
saveas(gcf, 'results/figures/Task04_Figure_06.png');
fprintf('Figure 6 saved: Nyquist plot (zoomed).\n');

% Stability assessment using Nyquist criterion
fprintf('Stability Assessment:\n');
fprintf('  Based on Bode plot: ');
if Pm2 > 0 && Gm2 > 1
    fprintf('System appears stable (positive margins).\n');
elseif Pm2 > 0 && Gm2 < 1
    fprintf('System may be unstable (gain margin < 1).\n');
else
    fprintf('System may be unstable (negative phase margin).\n');
end

% Check closed-loop poles for definitive answer
T2 = feedback(G2, 1);
poles_cl = pole(T2);
fprintf('  Closed-loop poles:\n');
fprintf('    %s\n', sprintf('%.4f %+.4fi  ', real(poles_cl), imag(poles_cl)));
if all(real(poles_cl) < 0)
    fprintf('  Closed-loop system is STABLE (all poles in LHP).\n\n');
else
    fprintf('  Closed-loop system is UNSTABLE (right-half-plane poles).\n\n');
end

% Step response to verify
figure;
step(T2);
title('Step Response of Closed-Loop System');
grid on;
saveas(gcf, 'results/figures/Task04_Figure_07.png');
fprintf('Figure 7 saved: Step response.\n');

fprintf('\nTask 4 completed.\n');
diary off;
