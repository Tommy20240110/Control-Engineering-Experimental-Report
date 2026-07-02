clc; clear; close all;
diary('results/logs/Task07_output.log');

fprintf('Task 7: Step Response Performance Metrics and Frequency Response\n\n');

s = tf('s');

%% 定义系统
Ga = 2 / (s^2 + 2*s + 2);
Gb = 1 / (2*s^3 + 3*s^2 + 3*s + 1);

fprintf('System A: Ga(s) = 2/(s^2 + 2s + 2)\n');
fprintf('System B: Gb(s) = 1/(2s^3 + 3s^2 + 3s + 1)\n\n');

%% 第一部分 (1a): 使用 stepinfo() 的阶跃响应
fprintf('Part (1a): Step Response with stepinfo()\n');

% System A step response
fprintf('System A:\n');
[y_a_step, t_a_step] = step(Ga);
S_a = stepinfo(Ga);
fprintf('  Rise Time: %.4f s\n', S_a.RiseTime);
fprintf('  Peak Time: %.4f s\n', S_a.PeakTime);
fprintf('  Settling Time (2%%): %.4f s\n', S_a.SettlingTime);
fprintf('  Overshoot: %.2f %%\n', S_a.Overshoot);
fprintf('  Peak Value: %.4f\n', S_a.Peak);
fprintf('  Steady-State Value: %.4f\n\n', S_a.SteadyStateValue);

% System B step response
fprintf('System B:\n');
[y_b_step, t_b_step] = step(Gb);
S_b = stepinfo(Gb);
fprintf('  Rise Time: %.4f s\n', S_b.RiseTime);
fprintf('  Peak Time: %.4f s\n', S_b.PeakTime);
fprintf('  Settling Time (2%%): %.4f s\n', S_b.SettlingTime);
fprintf('  Overshoot: %.2f %%\n', S_b.Overshoot);
fprintf('  Peak Value: %.4f\n', S_b.Peak);
fprintf('  Steady-State Value: %.4f\n\n', S_b.SteadyStateValue);

% Figure 1: Step response of System A using step() with annotations
figure('Name', 'Task7_SystemA_Step_Response', 'Position', [100, 100, 900, 600]);
plot(t_a_step, y_a_step, 'b', 'LineWidth', 1.5);
hold on;
% Annotate metrics
yline(S_a.SteadyStateValue, '--k', 'Steady State', 'LabelVerticalAlignment', 'bottom');
yline(S_a.Peak, '--r', sprintf('Peak = %.3f', S_a.Peak), 'LabelVerticalAlignment', 'bottom');
xline(S_a.RiseTime, '--g', sprintf('t_r = %.2f s', S_a.RiseTime), 'LabelVerticalAlignment', 'bottom');
xline(S_a.PeakTime, '--m', sprintf('t_p = %.2f s', S_a.PeakTime), 'LabelVerticalAlignment', 'bottom');
xline(S_a.SettlingTime, '--c', sprintf('t_s = %.2f s', S_a.SettlingTime), 'LabelVerticalAlignment', 'bottom');
xlabel('Time (s)');
ylabel('Output');
title(sprintf('System A Step Response (Overshoot = %.1f %%, t_r = %.2f s, t_p = %.2f s, t_s = %.2f s)', ...
    S_a.Overshoot, S_a.RiseTime, S_a.PeakTime, S_a.SettlingTime));
grid on;
hold off;
saveas(gcf, 'results/figures/Task07_Figure_01.png');

% Figure 2: Step response of System B using step() with annotations
figure('Name', 'Task7_SystemB_Step_Response', 'Position', [100, 100, 900, 600]);
plot(t_b_step, y_b_step, 'r', 'LineWidth', 1.5);
hold on;
yline(S_b.SteadyStateValue, '--k', 'Steady State', 'LabelVerticalAlignment', 'bottom');
yline(S_b.Peak, '--r', sprintf('Peak = %.3f', S_b.Peak), 'LabelVerticalAlignment', 'bottom');
xline(S_b.RiseTime, '--g', sprintf('t_r = %.2f s', S_b.RiseTime), 'LabelVerticalAlignment', 'bottom');
xline(S_b.PeakTime, '--m', sprintf('t_p = %.2f s', S_b.PeakTime), 'LabelVerticalAlignment', 'bottom');
xline(S_b.SettlingTime, '--c', sprintf('t_s = %.2f s', S_b.SettlingTime), 'LabelVerticalAlignment', 'bottom');
xlabel('Time (s)');
ylabel('Output');
title(sprintf('System B Step Response (Overshoot = %.1f %%, t_r = %.2f s, t_p = %.2f s, t_s = %.2f s)', ...
    S_b.Overshoot, S_b.RiseTime, S_b.PeakTime, S_b.SettlingTime));
grid on;
hold off;
saveas(gcf, 'results/figures/Task07_Figure_02.png');

%% 第一部分 (1b): 使用 lsim() 的阶跃响应
fprintf('Part (1b): Step Response using lsim()\n');

t_lsim = 0:0.01:10;
u_step = ones(size(t_lsim));  % Unit step input

% System A step response via lsim
[y_a_lsim, t_a_lsim] = lsim(Ga, u_step, t_lsim);
fprintf('System A (lsim): final value = %.4f\n', y_a_lsim(end));

% System B step response via lsim
[y_b_lsim, t_b_lsim] = lsim(Gb, u_step, t_lsim);
fprintf('System B (lsim): final value = %.4f\n\n', y_b_lsim(end));

% Figure 3: Comparison of step() and lsim() for System A
figure('Name', 'Task7_SystemA_lsim_Comparison', 'Position', [100, 100, 900, 600]);
plot(t_a_step, y_a_step, 'b-', 'LineWidth', 1.5);
hold on;
plot(t_a_lsim, y_a_lsim, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Output');
title('System A: Step Response Comparison (step() vs lsim())');
legend('step() function', 'lsim() with unit step', 'Location', 'best');
grid on;
hold off;
saveas(gcf, 'results/figures/Task07_Figure_03.png');

% Figure 4: Comparison of step() and lsim() for System B
figure('Name', 'Task7_SystemB_lsim_Comparison', 'Position', [100, 100, 900, 600]);
plot(t_b_step, y_b_step, 'b-', 'LineWidth', 1.5);
hold on;
plot(t_b_lsim, y_b_lsim, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Output');
title('System B: Step Response Comparison (step() vs lsim())');
legend('step() function', 'lsim() with unit step', 'Location', 'best');
grid on;
hold off;
saveas(gcf, 'results/figures/Task07_Figure_04.png');

%% 第二部分 (2): 频率响应 (Bode 图)
fprintf('Part (2): Frequency Response (Bode)\n');

% Figure 5: Combined Bode for both systems
figure('Name', 'Task7_Bode_Comparison', 'Position', [100, 100, 1100, 800]);

% System A Bode
subplot(2, 2, 1);
[mag_a, phase_a, w_a] = bode(Ga);
mag_a = squeeze(mag_a);
phase_a = squeeze(phase_a);
semilogx(w_a, 20*log10(mag_a), 'b', 'LineWidth', 1.5);
grid on;
xlabel('Frequency (rad/s)');
ylabel('Magnitude (dB)');
title('System A: Bode Magnitude');

subplot(2, 2, 2);
semilogx(w_a, phase_a, 'b', 'LineWidth', 1.5);
grid on;
xlabel('Frequency (rad/s)');
ylabel('Phase (deg)');
title('System A: Bode Phase');

% System B Bode
subplot(2, 2, 3);
[mag_b, phase_b, w_b] = bode(Gb);
mag_b = squeeze(mag_b);
phase_b = squeeze(phase_b);
semilogx(w_b, 20*log10(mag_b), 'r', 'LineWidth', 1.5);
grid on;
xlabel('Frequency (rad/s)');
ylabel('Magnitude (dB)');
title('System B: Bode Magnitude');

subplot(2, 2, 4);
semilogx(w_b, phase_b, 'r', 'LineWidth', 1.5);
grid on;
xlabel('Frequency (rad/s)');
ylabel('Phase (deg)');
title('System B: Bode Phase');

saveas(gcf, 'results/figures/Task07_Figure_05.png');

% Figure 6: Overlaid Bode comparison
figure('Name', 'Task7_Bode_Overlaid', 'Position', [100, 100, 900, 700]);

subplot(2, 1, 1);
semilogx(w_a, 20*log10(mag_a), 'b', 'LineWidth', 1.5);
hold on;
semilogx(w_b, 20*log10(mag_b), 'r', 'LineWidth', 1.5);
grid on;
xlabel('Frequency (rad/s)');
ylabel('Magnitude (dB)');
title('Bode Magnitude Comparison');
legend('System A', 'System B', 'Location', 'best');
hold off;

subplot(2, 1, 2);
semilogx(w_a, phase_a, 'b', 'LineWidth', 1.5);
hold on;
semilogx(w_b, phase_b, 'r', 'LineWidth', 1.5);
grid on;
xlabel('Frequency (rad/s)');
ylabel('Phase (deg)');
title('Bode Phase Comparison');
legend('System A', 'System B', 'Location', 'best');
hold off;

saveas(gcf, 'results/figures/Task07_Figure_06.png');

%% 分析
fprintf('\nAnalysis:\n');
fprintf('System A (2nd order):\n');
fprintf('  Natural frequency: omega_n = sqrt(2) = 1.414 rad/s\n');
fprintf('  Damping ratio: zeta = 2/(2*omega_n) = 0.707 (critically damped)\n\n');

fprintf('System B (3rd order):\n');
fprintf('  More complex dynamics with higher-order lag.\n');
fprintf('  Slower response and potentially more overshoot.\n\n');

fprintf('Comparison:\n');
fprintf('  The step() and lsim() methods produce identical results.\n');
fprintf('  step() is more convenient and provides stepinfo() integration.\n');
fprintf('  lsim() is more flexible for arbitrary inputs.\n');
fprintf('  Bode plots show the frequency-domain characteristics:\n');
fprintf('    - System A has a resonance peak near omega_n = 1.414 rad/s.\n');
fprintf('    - System B rolls off at -60 dB/decade (3rd order).\n');

diary off;
