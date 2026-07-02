% task2 选择合适的参数进行模拟 PID 控制.
clc;
clear;
close all;
diary('results/logs/Task02_output.log');

% 三阶对象模型 G(s) = 1 / (s + 1)^3.
s = tf('s');
G = 1 / (s + 1)^3;

% 手动计算临界增益 (对于 G(s)=1/(s+1)^3).
Kc = 8;
Tc = 2 * pi / sqrt(3);  % approx 3.6276

fprintf('临界增益 Kc = %.4f\n', Kc);
fprintf('临界振荡周期 Tc = %.4f 秒\n', Tc);

% Ziegler-Nichols PID 参数 (标准型)
Kp_zn = 0.6 * Kc;
Ti_zn = 0.5 * Tc;
Td_zn = 0.125 * Tc;

fprintf('\nZiegler-Nichols 整定参数:\n');
fprintf('Kp = %.4f\n', Kp_zn);
fprintf('Ti = %.4f\n', Ti_zn);
fprintf('Td = %.4f\n', Td_zn);

%% 1. 根轨迹图
figure;
rlocus(G);
title('Root Locus of Original System');
grid on;
saveas(gcf, 'results/figures/Task02_Figure_1.png');

%% 2. 使用整定后的 PID 控制器进行仿真
figure;

C_zn = pidstd(Kp_zn, Ti_zn, Td_zn, Inf);
G_cl_zn = feedback(C_zn * G, 1);
step(G_cl_zn);
grid on;
title('Step Response with Ziegler-Nichols PID Tuning');
xlabel('Time');
ylabel('Amplitude');
saveas(gcf, 'results/figures/Task02_Figure_2.png');

%% 3. 微调参数以获得更好的响应
figure;

Kp_tune = Kp_zn * 0.8;
Ti_tune = Ti_zn * 0.9;
Td_tune = Td_zn * 1.2;

C_tune = pidstd(Kp_tune, Ti_tune, Td_tune, Inf);
G_cl_tune = feedback(C_tune * G, 1);
step(G_cl_tune);
grid on;
title('Step Response with Fine-Tuned PID');
xlabel('Time');
ylabel('Amplitude');
saveas(gcf, 'results/figures/Task02_Figure_3.png');

%% 4. 性能指标对比
info_zn = stepinfo(G_cl_zn);
info_tune = stepinfo(G_cl_tune);

fprintf('\n性能指标对比:\n');
fprintf('指标\t\tZ-N PID\t\t微调后 PID\n');
fprintf('上升时间(s)\t%.4f\t\t%.4f\n', info_zn.RiseTime, info_tune.RiseTime);
fprintf('峰值时间(s)\t%.4f\t\t%.4f\n', info_zn.PeakTime, info_tune.PeakTime);
fprintf('超调量(%%)\t%.2f\t\t%.2f\n', info_zn.Overshoot, info_tune.Overshoot);
fprintf('调节时间(s)\t%.4f\t\t%.4f\n', info_zn.SettlingTime, info_tune.SettlingTime);

%% 5. 分析不同 PID 参数的影响
% (1) 不同 Kp 值的影响
figure;

Kp_test = [Kp_zn * 0.5, Kp_zn, Kp_zn * 1.5, Kp_zn * 2];
for i = 1:length(Kp_test)
    C_test = pidstd(Kp_test(i), Ti_zn, Td_zn, Inf);
    G_cl_test = feedback(C_test * G, 1);
    step(G_cl_test);
    hold on;
end

legend('Kp=0.5Kp_zn', 'Kp=Kp_zn', 'Kp=1.5Kp_zn', 'Kp=2Kp_zn', 'Location', 'southeast');
title('Effect of Kp on Step Response');
xlabel('Time');
ylabel('Amplitude');
grid on;
hold off;
saveas(gcf, 'results/figures/Task02_Figure_4.png');

% (2) 不同 Ti 值的影响
figure;

Ti_test = [Ti_zn * 0.5, Ti_zn, Ti_zn * 2, Ti_zn * 4];
for i = 1:length(Ti_test)
    C_test = pidstd(Kp_zn, Ti_test(i), Td_zn, Inf);
    G_cl_test = feedback(C_test * G, 1);
    step(G_cl_test);
    hold on;
end

legend('Ti=0.5Ti_zn', 'Ti=Ti_zn', 'Ti=2Ti_zn', 'Ti=4Ti_zn', 'Location', 'southeast');
title('Effect of Ti on Step Response');
xlabel('Time');
ylabel('Amplitude');
grid on;
hold off;
saveas(gcf, 'results/figures/Task02_Figure_5.png');

% (3) 不同 Td 值的影响
figure;

Td_test = [0, Td_zn * 0.5, Td_zn, Td_zn * 2];
for i = 1:length(Td_test)
    C_test = pidstd(Kp_zn, Ti_zn, Td_test(i), Inf);
    G_cl_test = feedback(C_test * G, 1);
    step(G_cl_test);
    hold on;
end

legend('Td=0', 'Td=0.5Td_zn', 'Td=Td_zn', 'Td=2Td_zn', 'Location', 'southeast');
title('Effect of Td on Step Response');
xlabel('Time');
ylabel('Amplitude');
grid on;
hold off;
saveas(gcf, 'results/figures/Task02_Figure_6.png');

%% 6. 选择最优参数并显示最终响应
figure;

Kp_opt = Kp_zn * 0.7;
Ti_opt = Ti_zn * 0.8;
Td_opt = Td_zn * 1.0;

C_opt = pidstd(Kp_opt, Ti_opt, Td_opt, Inf);
G_cl_opt = feedback(C_opt * G, 1);
step(G_cl_opt);
grid on;
title('Step Response with Optimal PID');
xlabel('Time');
ylabel('Amplitude');
saveas(gcf, 'results/figures/Task02_Figure_7.png');

info_opt = stepinfo(G_cl_opt);
fprintf('\n最优 PID 参数及性能:\n');
fprintf('Kp = %.4f, Ti = %.4f, Td = %.4f\n', Kp_opt, Ti_opt, Td_opt);
fprintf('上升时间 = %.4f\n', info_opt.RiseTime);
fprintf('超调量 = %.2f %%\n', info_opt.Overshoot);
fprintf('调节时间 = %.4f\n', info_opt.SettlingTime);

diary off;
