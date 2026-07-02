%% 典型输入信号下求解系统的输出响应
clc;
clear;
close all;
diary('results/logs/Task02_output.log');

%% 定义系统传递函数
s = tf('s');
G = 20/(s^2 + 2*s + 20);

%% 阶跃响应 step()
figure('Name', 'Step Response', 'Position', [100, 100, 800, 600]);
subplot(2,2,1);
step(G);
title('System Step Response');
grid on;

%% 脉冲响应 impulse()
subplot(2,2,2);
impulse(G);
title('System Impulse Response');
grid on;

%% 斜坡响应 (通过积分器实现)
% 斜坡输入 = t * 1(t), 对阶跃响应积分
t = 0:0.01:10;
u_ramp = t;
[y_ramp, t_out] = lsim(G, u_ramp, t);
subplot(2,2,3);
plot(t_out, y_ramp, 'b-', 'LineWidth', 1.5);
hold on;
plot(t, u_ramp, 'r--', 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Output');
title('System Ramp Response');
legend('System Output', 'Ramp Input');
grid on;

%% 抛物线响应 (加速度输入)
% 加速度输入 = 0.5*t^2
u_para = 0.5 * t.^2;
[y_para, t_out] = lsim(G, u_para, t);
subplot(2,2,4);
plot(t_out, y_para, 'b-', 'LineWidth', 1.5);
hold on;
plot(t, u_para, 'r--', 'LineWidth', 1);
xlabel('Time (s)');
ylabel('Output');
title('System Parabolic Response');
legend('System Output', 'Parabolic Input');
grid on;
saveas(gcf, 'results/figures/Task02_Figure_01.png');

%% 不同输入响应的比较
figure('Name', 'Comparison of Different Input Responses', 'Position', [150, 150, 800, 400]);

% 阶跃响应
[y_step, t_step] = step(G);
subplot(1,3,1);
plot(t_step, y_step, 'b-', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Output');
title('Step Response');
grid on;

% 脉冲响应
[y_imp, t_imp] = impulse(G);
subplot(1,3,2);
plot(t_imp, y_imp, 'r-', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Output');
title('Impulse Response');
grid on;

% 初始条件响应
[y_ic, t_ic] = initial(ss(G), [1; 0], 10);
subplot(1,3,3);
plot(t_ic, y_ic, 'g-', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Output');
title('Initial Condition Response (x0=[1;0])');
grid on;
saveas(gcf, 'results/figures/Task02_Figure_02.png');

%% 打印结果
disp('响应分析结果:');
disp('1. 阶跃响应: 显示系统的跟踪能力');
disp('2. 脉冲响应: 显示系统的动态特性');
disp('3. 斜坡响应: 显示系统对匀速信号的跟踪能力');
disp('4. 抛物线响应: 显示系统对匀加速信号的跟踪能力');
diary off;
