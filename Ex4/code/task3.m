clc; clear; close all;
diary('results/logs/Task03_output.log');

fprintf('Task 3: Second-Order System Step Response Analysis\n\n');

s = tf('s');

%% 原始系统: G(s) = 20/(s^2 + 2s + 20)
omega_n_orig = sqrt(20);
zeta_orig = 1 / omega_n_orig;
G_orig = omega_n_orig^2 / (s^2 + 2*zeta_orig*omega_n_orig*s + omega_n_orig^2);
fprintf('Original system:\n');
fprintf('  G(s) = %.2f/(s^2 + %.2fs + %.2f)\n', omega_n_orig^2, 2*zeta_orig*omega_n_orig, omega_n_orig^2);
fprintf('  omega_n = %.4f, zeta = %.4f\n\n', omega_n_orig, zeta_orig);

%% 第一部分 (1a): 阻尼比的影响 (固定 omega_n, 改变 zeta)
fprintf('Part (1a): Damping Ratio Variation\n');
zeta_vals = [zeta_orig, 0.5, 3];
wn_fixed = omega_n_orig;
leg_str = {};
figure('Name', 'Task3_Damping_Ratio_Effect', 'Position', [100, 100, 900, 600]);
hold on;
colors = {'b', 'r', 'g'};
for i = 1:length(zeta_vals)
    z = zeta_vals(i);
    Gi = wn_fixed^2 / (s^2 + 2*z*wn_fixed*s + wn_fixed^2);
    [y, t] = step(Gi);
    plot(t, y, colors{i}, 'LineWidth', 1.5);
    leg_str{i} = sprintf('zeta = %.2f', z);
    fprintf('  zeta = %.2f: G(s) = %.2f/(s^2 + %.2fs + %.2f)\n', z, wn_fixed^2, 2*z*wn_fixed, wn_fixed^2);
end
xlabel('Time (s)');
ylabel('Output');
title('Step Response with Different Damping Ratios (omega_n = 4.47)');
legend(leg_str, 'Location', 'best');
grid on;
hold off;
saveas(gcf, 'results/figures/Task03_Figure_01.png');
fprintf('\n');

%% 第一部分 (1b): 自然频率的影响 (固定 zeta, 改变 omega_n)
fprintf('Part (1b): Natural Frequency Variation\n');
omega_n_ref = sqrt(10);
omega_n_vals = [omega_n_ref/3, omega_n_ref, 3*omega_n_ref, omega_n_orig];
z_fixed = zeta_orig;
label_str = {};
figure('Name', 'Task3_Natural_Frequency_Effect', 'Position', [100, 100, 900, 600]);
hold on;
colors = {'c', 'm', 'k', 'b'};
for i = 1:length(omega_n_vals)
    wn = omega_n_vals(i);
    Gi = wn^2 / (s^2 + 2*z_fixed*wn*s + wn^2);
    [y, t] = step(Gi);
    plot(t, y, colors{i}, 'LineWidth', 1.5);
    label_str{i} = sprintf('omega_n = %.2f', wn);
    fprintf('  omega_n = %.4f: G(s) = %.2f/(s^2 + %.2fs + %.2f)\n', wn, wn^2, 2*z_fixed*wn, wn^2);
end
xlabel('Time (s)');
ylabel('Output');
title(sprintf('Step Response with Different Natural Frequencies (zeta = %.2f)', z_fixed));
legend(label_str, 'Location', 'best');
grid on;
hold off;
saveas(gcf, 'results/figures/Task03_Figure_02.png');
fprintf('\n');

%% 第二部分: G1 到 G4 的阶跃响应比较
fprintf('Part (2): Comparison of Systems G1-G4\n');

G1 = 3*s / (s^2 + 3*s + 10);
G2 = (3*s + 10) / (s^2 + 3*s + 10);
G3 = (s^2 + s) / (s^2 + 3*s + 10);
G4 = (s^2 + s + 10) / (s^2 + 3*s + 10);

sys_list = {G1, G2, G3, G4};
sys_names = {'G1(s) = 3s/(s^2+3s+10)', 'G2(s) = (3s+10)/(s^2+3s+10)', ...
             'G3(s) = (s^2+s)/(s^2+3s+10)', 'G4(s) = (s^2+s+10)/(s^2+3s+10)'};

% 图 3: 单独子图
figure('Name', 'Task3_Individual_Step_Responses_G1_G4', 'Position', [100, 100, 1000, 800]);
for i = 1:4
    subplot(2, 2, i);
    step(sys_list{i});
    title(sprintf('Step Response of %s', sys_names{i}));
    grid on;
    xlabel('Time (s)');
    ylabel('Output');
end
saveas(gcf, 'results/figures/Task03_Figure_03.png');

% 图 4: 组合图
figure('Name', 'Task3_Combined_Step_Response_G1_G4', 'Position', [100, 100, 900, 600]);
hold on;
colors2 = {'b', 'r', 'g', 'm'};
for i = 1:4
    [y, t] = step(sys_list{i});
    plot(t, y, colors2{i}, 'LineWidth', 1.5);
    fprintf('  %s: initial value = %.2f, steady-state = %.2f\n', sys_names{i}, y(1), y(end));
end
xlabel('Time (s)');
ylabel('Output');
title('Combined Step Response Comparison of G1-G4');
legend(sys_names, 'Location', 'best');
grid on;
hold off;
saveas(gcf, 'results/figures/Task03_Figure_04.png');

%% 分析
fprintf('\nAnalysis:\n');
fprintf('Part (1a) - Damping Ratio Effect:\n');
fprintf('  As zeta increases, overshoot decreases and rise time increases.\n');
fprintf('  zeta=0.22 (original): underdamped, moderate overshoot.\n');
fprintf('  zeta=0.50: underdamped, reduced overshoot.\n');
fprintf('  zeta=3.00: overdamped, no overshoot, sluggish response.\n\n');

fprintf('Part (1b) - Natural Frequency Effect:\n');
fprintf('  Larger omega_n shifts the response left (faster dynamics).\n');
fprintf('  omega_n=1.05 (sqrt(10)/3): slow response, low-frequency oscillation.\n');
fprintf('  omega_n=3.16 (sqrt(10)): moderate speed.\n');
fprintf('  omega_n=9.49 (3*sqrt(10)): fast response, high-frequency oscillation.\n');
fprintf('  omega_n=4.47 (sqrt(20), original): between sqrt(10) and 3*sqrt(10).\n\n');

fprintf('Part (2) - Zero and Steady-State Analysis:\n');
fprintf('  G1: zero at s=0 (derivative action), strictly proper (num deg < den deg).\n');
fprintf('      Initial value = 0, steady-state = 0.\n');
fprintf('  G2: zero at s=-10/3, strictly proper. Initial value = 0, steady-state = 1.\n');
fprintf('  G3: zeros at s=0 and s=-1, proper (num deg = den deg).\n');
fprintf('      Initial value = 1 (non-zero), steady-state = 0.\n');
fprintf('  G4: complex zeros, proper. Initial value = 1 (non-zero), steady-state = 1.\n');
fprintf('  Zeros affect the transient shape: LHP zeros increase overshoot;\n');
fprintf('  zeros at the origin add derivative action (initial zero output);\n');
fprintf('  non-zero initial values arise when numerator degree = denominator degree.\n');
fprintf('  Steady-state value equals the DC gain G(0).\n');

diary off;
