%% 任务5: PID控制器设计
% Example 7-6: Phase margins before and after correction
% Exercise 7-20: PID controller design using pole placement
% Fixed: added mkdir for output directories.

clc;
clear;
close all;

% Ensure output directories exist
if ~exist('results/logs', 'dir'), mkdir('results/logs'); end
if ~exist('results/figures', 'dir'), mkdir('results/figures'); end

diary('results/logs/Task05_output.log');

fprintf('Task 5: PID Controller Design\n\n');

%% 第1部分: 示例7-6 校正前后相角裕度对比
fprintf('Part 1: Phase Margin Analysis (Example 7-6)\n\n');

% System before correction: G1(s) = 100/(s(0.04s+1)(0.01s+1))
num1 = [100];
den1 = conv([1, 0], conv([0.04, 1], [0.01, 1]));
G1 = tf(num1, den1);

fprintf('Before correction: G1(s) = 100/(s(0.04s+1)(0.01s+1))\n');
disp(G1);
fprintf('\n');

% Bode plot with margins before correction
figure;
margin(G1);
title('Bode Plot - Before Correction');
grid on;
saveas(gcf, 'results/figures/Task05_Figure_01.png');
fprintf('Figure 1 saved: Bode plot before correction.\n');

[Gm1, Pm1, Wcg1, Wcp1] = margin(G1);
fprintf('Before Correction:\n');
fprintf('  Gain Margin = %.4f (%.2f dB)\n', Gm1, 20*log10(Gm1));
fprintf('  Phase Margin = %.4f deg\n', Pm1);
fprintf('  Phase crossover freq = %.4f rad/s\n', Wcg1);
fprintf('  Gain crossover freq = %.4f rad/s\n', Wcp1);
if Pm1 > 0 && Gm1 > 1
    fprintf('  System is stable.\n\n');
else
    fprintf('  System is unstable.\n\n');
end

% System after correction: G2(s) = 100(0.5s+1)/(s(5s+1)(0.04s+1)(0.01s+1))
num2 = 100 * [0.5, 1];
den2 = conv([1, 0], conv([5, 1], conv([0.04, 1], [0.01, 1])));
G2 = tf(num2, den2);

fprintf('After correction: G2(s) = 100(0.5s+1)/(s(5s+1)(0.04s+1)(0.01s+1))\n');
disp(G2);
fprintf('\n');

% Bode plot with margins after correction
figure;
margin(G2);
title('Bode Plot - After Correction');
grid on;
saveas(gcf, 'results/figures/Task05_Figure_02.png');
fprintf('Figure 2 saved: Bode plot after correction.\n');

[Gm2, Pm2, Wcg2, Wcp2] = margin(G2);
fprintf('After Correction:\n');
fprintf('  Gain Margin = %.4f (%.2f dB)\n', Gm2, 20*log10(Gm2));
fprintf('  Phase Margin = %.4f deg\n', Pm2);
fprintf('  Phase crossover freq = %.4f rad/s\n', Wcg2);
fprintf('  Gain crossover freq = %.4f rad/s\n', Wcp2);
if Pm2 > 0 && Gm2 > 1
    fprintf('  System is stable.\n\n');
else
    fprintf('  System is unstable.\n\n');
end

% Comparison
fprintf('Comparison:\n');
fprintf('  Phase margin improved from %.2f to %.2f degrees.\n', Pm1, Pm2);
fprintf('  Gain margin improved from %.2f dB to %.2f dB.\n\n', 20*log10(Gm1), 20*log10(Gm2));

% Step response comparison
figure;
[y1, t1] = step(feedback(G1, 1));
[y2, t2] = step(feedback(G2, 1));
plot(t1, y1, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Before correction');
hold on;
plot(t2, y2, 'r-', 'LineWidth', 1.5, 'DisplayName', 'After correction');
hold off;
xlabel('Time (s)');
ylabel('Amplitude');
title('Step Response Comparison: Before vs After Correction');
legend('show');
grid on;
saveas(gcf, 'results/figures/Task05_Figure_03.png');
fprintf('Figure 3 saved: Step response comparison.\n\n');

%% 第2部分: 习题7-20 极点配置法PID控制器设计
fprintf('Part 2: PID Controller Design (Exercise 7-20)\n\n');

% Plant: G0(s) = 100/(s(10s+1))
num0 = [100];
den0 = [10, 1, 0];
G0 = tf(num0, den0);

fprintf('Plant: G0(s) = 100/(s(10s+1))\n');
disp(G0);
fprintf('\n');

% Desired closed-loop poles: -2+j1, -2-j1, -5
desired_poles = [-2+1i, -2-1i, -5];

fprintf('Desired closed-loop poles:\n');
fprintf('  p1 = -2 + j1\n');
fprintf('  p2 = -2 - j1\n');
fprintf('  p3 = -5\n\n');

% PID gains designed via coefficient matching
Kp = 2.5;
Ki = 2.5;
Kd = 0.89;

fprintf('PID Controller Parameters (designed):\n');
fprintf('  Kp (proportional) = %.4f\n', Kp);
fprintf('  Ki (integral) = %.4f\n', Ki);
fprintf('  Kd (derivative) = %.4f\n\n', Kd);

% Build PID controller
s = tf('s');
C = Kp + Ki/s + Kd*s;
fprintf('PID Controller: C(s) = %.4f + %.4f/s + %.4f*s\n\n', Kp, Ki, Kd);

% Closed-loop system
G_cl = feedback(C * G0, 1);
fprintf('Closed-loop transfer function:\n');
disp(G_cl);
fprintf('\n');

% Verify pole placement
poles_actual = pole(G_cl);
fprintf('Actual closed-loop poles:\n');
for i = 1:length(poles_actual)
    fprintf('  p%d = %.4f %+.4fi\n', i, real(poles_actual(i)), imag(poles_actual(i)));
end
fprintf('\n');

% Check if poles match desired
fprintf('Pole placement verification:\n');
fprintf('  Desired: -2+j1, -2-j1, -5\n');
fprintf('  Achieved: ');
for i = 1:length(poles_actual)
    fprintf('(%.4f%+.4fi) ', real(poles_actual(i)), imag(poles_actual(i)));
end
fprintf('\n\n');

% Plot step response
figure;
step(G_cl);
title('Step Response with PID Controller (Pole Placement)');
grid on;
saveas(gcf, 'results/figures/Task05_Figure_04.png');
fprintf('Figure 4 saved: Step response with PID controller.\n');

% Step response metrics
try
    info_pid = stepinfo(G_cl);
    fprintf('Step Response Metrics with PID:\n');
    fprintf('  Rise time = %.4f s\n', info_pid.RiseTime);
    fprintf('  Peak time = %.4f s\n', info_pid.PeakTime);
    fprintf('  Overshoot = %.2f %%\n', info_pid.Overshoot);
    fprintf('  Settling time = %.4f s\n', info_pid.SettlingTime);
    fprintf('  Final value = %.4f\n\n', dcgain(G_cl));
catch
    fprintf('Stepinfo computation failed.\n\n');
end

% Bode plot of the compensated system
figure;
margin(C * G0);
title('Bode Plot of Compensated System (C(s)*G0(s))');
grid on;
saveas(gcf, 'results/figures/Task05_Figure_05.png');
fprintf('Figure 5 saved: Bode plot of compensated system.\n');

fprintf('\nTask 5 completed.\n');
diary off;
