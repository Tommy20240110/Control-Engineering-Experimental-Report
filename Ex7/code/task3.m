%% 任务3: Bode图与Nyquist图
% Example 4-8: Bode plot with gain/phase margins
% Example 4-10: Nyquist plot
% Exercise 4-15: Nyquist plots for two systems
% Fixed: added mkdir for output directories.

clc;
clear;
close all;

% Ensure output directories exist
if ~exist('results/logs', 'dir'), mkdir('results/logs'); end
if ~exist('results/figures', 'dir'), mkdir('results/figures'); end

diary('results/logs/Task03_output.log');

fprintf('Task 3: Bode and Nyquist Plots\n\n');

%% 第1部分: 示例4-8 Bode图
fprintf('Part 1: Bode Plot (Example 4-8)\n\n');

% System: G(s) = 50 / (25s^2 + 2s + 1)
num = [50];
den = [25, 2, 1];
G = tf(num, den);

fprintf('System: G(s) = 50 / (25s^2 + 2s + 1)\n\n');

% Bode plot with margin
figure;
margin(G);
title('Bode Plot of G(s) = 50/(25s^2+2s+1)');
grid on;
saveas(gcf, 'results/figures/Task03_Figure_01.png');
fprintf('Figure 1 saved: Bode plot with margins.\n');

% Get gain and phase margins
[Gm, Pm, Wcg, Wcp] = margin(G);
fprintf('Gain Margin (Gm) = %.4f (%.2f dB)\n', Gm, 20*log10(Gm));
fprintf('Phase Margin (Pm) = %.4f deg\n', Pm);
fprintf('Phase crossover frequency (Wcg) = %.4f rad/s\n', Wcg);
fprintf('Gain crossover frequency (Wcp) = %.4f rad/s\n\n', Wcp);

%% 第2部分: 示例4-10 Nyquist图
fprintf('Part 2: Nyquist Plot (Example 4-10)\n\n');

figure;
nyquist(G);
title('Nyquist Plot of G(s) = 50/(25s^2+2s+1)');
grid on;
saveas(gcf, 'results/figures/Task03_Figure_02.png');
fprintf('Figure 2 saved: Nyquist plot.\n');

% Also show zoomed Nyquist around critical point
figure;
nyquist(G);
title('Nyquist Plot of G(s) = 50/(25s^2+2s+1) (Zoomed)');
axis([-2, 1, -2, 2]);
grid on;
saveas(gcf, 'results/figures/Task03_Figure_03.png');
fprintf('Figure 3 saved: Nyquist plot (zoomed).\n\n');

%% 第3部分: 习题4-15 两个系统的Nyquist图
fprintf('Part 3: Nyquist Plots (Exercise 4-15)\n\n');

% System (1): G(s) = 1/((s+1)(2s+1))
num1 = [1];
den1 = conv([1, 1], [2, 1]);
G1 = tf(num1, den1);

fprintf('System (1): G(s) = 1/((s+1)(2s+1))\n\n');

figure;
nyquist(G1);
title('Nyquist Plot of G(s) = 1/((s+1)(2s+1))');
grid on;
saveas(gcf, 'results/figures/Task03_Figure_04.png');
fprintf('Figure 4 saved: Nyquist plot for System (1).\n');

% System (2): G(s) = 1/(s^2(s+1)(2s+1))
num2 = [1];
den2 = conv([1, 0, 0], conv([1, 1], [2, 1]));
G2 = tf(num2, den2);

fprintf('System (2): G(s) = 1/(s^2(s+1)(2s+1))\n\n');

figure;
nyquist(G2);
title('Nyquist Plot of G(s) = 1/(s^2(s+1)(2s+1))');
grid on;
saveas(gcf, 'results/figures/Task03_Figure_05.png');
fprintf('Figure 5 saved: Nyquist plot for System (2).\n');

% Compare the two Nyquist plots
figure;
subplot(1, 2, 1);
nyquist(G1);
title('System (1): G(s)=1/((s+1)(2s+1))');
grid on;
subplot(1, 2, 2);
nyquist(G2);
title('System (2): G(s)=1/(s^2(s+1)(2s+1))');
grid on;
saveas(gcf, 'results/figures/Task03_Figure_06.png');
fprintf('Figure 6 saved: Comparison of Nyquist plots.\n');

fprintf('\nTask 3 completed.\n');
diary off;
