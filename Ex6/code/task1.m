% task1 研究闭环系统在不同控制情况下的阶跃响应.
clc;
clear;
close all;
diary('results/logs/Task01_output.log');

% 三阶对象模型 G(s) = 1 / (s + 1)^3.
s = tf('s');
G = 1 / (s + 1)^3;

%% 1. Ti -> inf, Td -> 0 时, 在不同 Kp 值下, 闭环系统的阶跃响应
figure;

Kp_list = [0.5, 1, 2, 3, 4, 5];
for i = 1:length(Kp_list)
    Kp = Kp_list(i);
    % 纯比例控制: Ti = inf, Td = 0, N = Inf.
    C = pidstd(Kp, Inf, 0, Inf);
    G_cl = feedback(C * G, 1);
    step(G_cl);
    hold on;
end

legend('Kp=0.5', 'Kp=1', 'Kp=2', 'Kp=3', 'Kp=4', 'Kp=5', 'Location', 'southeast');
title('Step Response for Different Kp Values (Ti->inf, Td->0)');
xlabel('Time');
ylabel('Amplitude');
grid on;
hold off;
saveas(gcf, 'results/figures/Task01_Figure_1.png');

%% 2. Kp = 1, Td -> 0 时, 在不同 Ti 值下, 闭环系统的阶跃响应
Ti_list = [0.5, 1, 2, 5, 10];

% 判断稳定性, 分组合并.
stable_Ti = [];
unstable_Ti = [];

for i = 1:length(Ti_list)
    Ti = Ti_list(i);
    C = pidstd(1, Ti, 0, Inf);
    G_cl = feedback(C * G, 1);
    poles = pole(G_cl);
    if all(real(poles) < 0)
        stable_Ti = [stable_Ti, Ti];
    else
        unstable_Ti = [unstable_Ti, Ti];
    end
end

% 子图1: 稳定的曲线
figure;
subplot(1, 2, 1);
for i = 1:length(stable_Ti)
    Ti = stable_Ti(i);
    C = pidstd(1, Ti, 0, Inf);
    G_cl = feedback(C * G, 1);
    step(G_cl);
    hold on;
end
legend(arrayfun(@(x) sprintf('Ti=%.1f', x), stable_Ti, 'UniformOutput', false), 'Location', 'southeast');
title('Stable Step Responses');
xlabel('Time');
ylabel('Amplitude');
grid on;
hold off;

% 子图2: 不稳定的曲线 (限时5秒)
subplot(1, 2, 2);
for i = 1:length(unstable_Ti)
    Ti = unstable_Ti(i);
    C = pidstd(1, Ti, 0, Inf);
    G_cl = feedback(C * G, 1);
    [y, t] = step(G_cl, 5);
    plot(t, y);
    hold on;
end
legend(arrayfun(@(x) sprintf('Ti=%.1f', x), unstable_Ti, 'UniformOutput', false), 'Location', 'southeast');
title('Unstable Step Responses (5 sec Limit)');
xlabel('Time');
ylabel('Amplitude');
grid on;
hold off;
saveas(gcf, 'results/figures/Task01_Figure_2.png');

%% 3. Kp = Ti = 1 时, 在不同 Td 值下, 闭环系统的阶跃响应
figure;

Td_list = [0, 0.5, 1, 2, 3, 4];
for i = 1:length(Td_list)
    Td = Td_list(i);
    C = pidstd(1, 1, Td, Inf);
    G_cl = feedback(C * G, 1);
    step(G_cl);
    hold on;
end

legend('Td=0', 'Td=0.5', 'Td=1', 'Td=2', 'Td=3', 'Td=4', 'Location', 'southeast');
title('Step Response for Different Td Values (Kp=Ti=1)');
xlabel('Time');
ylabel('Amplitude');
grid on;
hold off;
saveas(gcf, 'results/figures/Task01_Figure_3.png');

diary off;
