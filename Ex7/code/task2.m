%% 任务2: 脉冲与阶跃响应分析
% Example 3-5: Unit impulse response, compute natural frequency and damping ratio
% Exercise 3-7: Step response metrics, effect of gain K on dynamics

clc;
clear;
close all;
diary('results/logs/Task02_output.log');

fprintf('Task 2: Impulse and Step Response Analysis\n\n');

%% 第1部分: 示例3-5 单位脉冲响应
fprintf('Part 1: Unit Impulse Response (Example 3-5)\n\n');

% Define the system: G(s) = 50 / (25s^2 + 2s + 1)
num1 = [50];
den1 = [25, 2, 1];
G1 = tf(num1, den1);

fprintf('System: G(s) = 50 / (25s^2 + 2s + 1)\n\n');

% Compute natural frequency and damping ratio
% Standard 2nd order form: G(s) = K*wn^2 / (s^2 + 2*zeta*wn*s + wn^2)
% Our denominator: 25s^2 + 2s + 1 = 25*(s^2 + 0.08s + 0.04)
% So wn^2 = 0.04, 2*zeta*wn = 0.08
wn = sqrt(1/25);    % natural frequency
zeta = (2/25) / (2*wn);  % damping ratio

fprintf('Natural frequency (wn) = %.4f rad/s\n', wn);
fprintf('Damping ratio (zeta) = %.4f\n\n', zeta);

% Plot unit impulse response
figure;
impulse(G1);
title('Unit Impulse Response of G(s) = 50/(25s^2+2s+1)');
grid on;
saveas(gcf, 'results/figures/Task02_Figure_01.png');
fprintf('Figure 1 saved: Unit impulse response.\n\n');

% Get impulse response data
[y_imp, t_imp] = impulse(G1);
fprintf('Impulse response: max amplitude = %.4f at t = %.4f s\n\n', ...
    max(y_imp), t_imp(y_imp == max(y_imp)));

%% 第2部分: 习题3-7 阶跃响应分析
fprintf('Part 2: Step Response Analysis (Exercise 3-7)\n\n');

% System: G(s) = 1/(s(s+1)), unit feedback
% Closed-loop: T(s) = G/(1+G) = 1/(s^2 + s + 1)
num2 = [1];
den2 = [1, 1, 0];
G2 = tf(num2, den2);  % open loop

% Closed-loop transfer function
T2 = feedback(G2, 1);
fprintf('Open-loop: G(s) = 1/(s(s+1))\n');
fprintf('Closed-loop: T(s) = 1/(s^2 + s + 1)\n\n');

% Step response and metrics
figure;
step(T2);
title('Step Response of T(s) = 1/(s^2+s+1)');
grid on;
saveas(gcf, 'results/figures/Task02_Figure_02.png');
fprintf('Figure 2 saved: Step response of closed-loop system.\n');

% Get step response metrics
info = stepinfo(T2);
fprintf('Step Response Metrics (G(s)=1/(s(s+1))):\n');
fprintf('  Rise time (tr) = %.4f s\n', info.RiseTime);
fprintf('  Peak time (tp) = %.4f s\n', info.PeakTime);
fprintf('  Maximum overshoot (Mp) = %.2f %%\n', info.Overshoot);
fprintf('  Settling time (ts) = %.4f s\n\n', info.SettlingTime);

%% 第3部分: 增益K对动态特性的影响
fprintf('Part 3: Effect of Gain K on Step Response\n\n');

% G(s) = K/(s(s+1)) for K = 0.5, 1, 2, 5, 10
K_values = [0.5, 1, 2, 5, 10];
colors = {'b', 'r', 'g', 'm', 'k'};
markers = {'o', 's', 'd', '^', 'v'};

figure;
hold on;
for i = 1:length(K_values)
    K = K_values(i);
    Gk = tf(K, [1, 1, 0]);  % K/(s(s+1))
    Tk = feedback(Gk, 1);
    [y, t] = step(Tk);
    plot(t, y, colors{i}, 'LineWidth', 1.5, 'DisplayName', sprintf('K=%.1f', K));
end
hold off;
xlabel('Time (s)');
ylabel('Amplitude');
title('Step Response for Different K Values');
legend('show', 'Location', 'southeast');
grid on;
saveas(gcf, 'results/figures/Task02_Figure_03.png');
fprintf('Figure 3 saved: Step responses for different K values.\n');

% Compute and display metrics for each K
fprintf('Performance metrics for different K values:\n');
fprintf('K\tRise Time\tPeak Time\tOvershoot(%%)\tSettling Time\n');
for i = 1:length(K_values)
    K = K_values(i);
    Gk = tf(K, [1, 1, 0]);
    Tk = feedback(Gk, 1);
    info_k = stepinfo(Tk);
    fprintf('%.1f\t%.4f\t\t%.4f\t\t%.2f\t\t%.4f\n', ...
        K, info_k.RiseTime, info_k.PeakTime, info_k.Overshoot, info_k.SettlingTime);
end

fprintf('\n');
fprintf('Analysis: As K increases, the response becomes faster (shorter rise time)\n');
fprintf('but overshoot increases, leading to more oscillatory behavior.\n');
fprintf('For K=0.5 the system is overdamped, for K=1 it is critically damped,\n');
fprintf('and for larger K it becomes underdamped with increasing overshoot.\n');

fprintf('\nTask 2 completed.\n');
diary off;
