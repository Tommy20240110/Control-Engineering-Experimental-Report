%% 任务6: 根轨迹分析
% Example 8-12: Root locus of G(s) = K/(s(s+2)(s+5))
% Exercise 8-8: Root locus with parameter variation (Kh)
% Fixed: added mkdir for output directories, removed interactive functions,
% improved robustness.

clc;
clear;
close all;

% Ensure output directories exist
if ~exist('results/logs', 'dir'), mkdir('results/logs'); end
if ~exist('results/figures', 'dir'), mkdir('results/figures'); end

diary('results/logs/Task06_output.log');

fprintf('Task 6: Root Locus Analysis\n\n');

%% 第1部分: 示例8-12 根轨迹
fprintf('Part 1: Root Locus (Example 8-12)\n\n');

% System: G(s) = K/(s(s+2)(s+5))
num1 = [1];
den1 = conv([1, 0], conv([1, 2], [1, 5]));
G1 = tf(num1, den1);

fprintf('System: G(s) = K/(s(s+2)(s+5))\n');
disp(G1);
fprintf('\n');

% Plot root locus
figure;
rlocus(G1);
title('Root Locus of G(s) = K/(s(s+2)(s+5))');
grid on;
saveas(gcf, 'results/figures/Task06_Figure_01.png');
fprintf('Figure 1 saved: Root locus.\n');

% Find gain at selected point on root locus (non-interactive)
% Characteristic equation: s(s+2)(s+5) + K = 0
% => s^3 + 7s^2 + 10s + K = 0
% For a point on the locus, K = -s(s+2)(s+5)

s_test = -1 + 1i;  % Test point
K_val_at_point = -s_test*(s_test+2)*(s_test+5);
fprintf('At test point s = %.4f %+.4fi:\n', real(s_test), imag(s_test));
fprintf('  Corresponding gain K = %.4f\n\n', abs(K_val_at_point));

% Verify this point relative to root locus
G1_s = polyval(num1, s_test) / polyval(den1, s_test);
angle_G1 = angle(G1_s) * 180/pi;
fprintf('Angle of G(s) at test point: %.2f deg\n', angle_G1);
fprintf('Angle condition for root locus: %+.2f deg (target: +/-180 deg)\n', ...
    mod(angle_G1 + 180, 360) - 180);
fprintf('  (A value near 0 indicates the point is on the root locus)\n\n');

% Find closed-loop poles for this K
fprintf('Closed-loop poles for K = %.4f:\n', abs(K_val_at_point));
G1_cl = feedback(abs(K_val_at_point) * G1, 1);
p1 = pole(G1_cl);
for i = 1:length(p1)
    fprintf('  p%d = %.4f %+.4fi\n', i, real(p1(i)), imag(p1(i)));
end
fprintf('\n');

% Find gain at breakaway point
% The breakaway occurs where dK/ds = 0
% K = -(s^3 + 7s^2 + 10s)
% dK/ds = -(3s^2 + 14s + 10) = 0
% s = (-14 +/- sqrt(196-120))/6

s_break = (-14 + sqrt(76))/6;
K_break = -(s_break^3 + 7*s_break^2 + 10*s_break);
fprintf('Breakaway point: s = %.4f\n', s_break);
fprintf('Gain at breakaway: K = %.4f\n\n', K_break);

%% 第2部分: 习题8-8 参数变化时的根轨迹
fprintf('Part 2: Root Locus with Parameter Variation (Exercise 8-8)\n\n');

%% Part (1): Kh = 0.5, K from 0 to inf
fprintf('Part (1): Kh = 0.5, vary K from 0 to inf\n\n');

Kh = 0.5;
% Open-loop: G(s)H(s) = K * (1+Kh*s)/(s(s+1))
num_ol = [Kh, 1];   % 0.5*s + 1
den_ol = [1, 1, 0]; % s^2 + s
G_ol1 = tf(num_ol, den_ol);

fprintf('Equivalent open-loop: G(s)H(s) = K*(1+%.1f*s)/(s(s+1))\n', Kh);
disp(G_ol1);
fprintf('\n');

figure;
rlocus(G_ol1);
title(sprintf('Root Locus for Kh=%.1f, K from 0 to inf', Kh));
grid on;
saveas(gcf, 'results/figures/Task06_Figure_02.png');
fprintf('Figure 2 saved: Root locus for Kh=0.5, varying K.\n\n');

%% Part (2): Kh = 0.5, K = 10, find closed-loop poles and zeta
fprintf('Part (2): Kh = 0.5, K = 10\n\n');

K_val = 10;
Kh_val = 0.5;

% Closed-loop characteristic: s(s+1) + K*(1+Kh*s) = 0
% => s^2 + s + K + K*Kh*s = 0
% => s^2 + (1 + K*Kh)*s + K = 0

fprintf('Characteristic equation: s^2 + (1+K*Kh)*s + K = 0\n');
fprintf('With K=%d, Kh=%.1f: s^2 + %.1f*s + %d = 0\n', K_val, Kh_val, 1+K_val*Kh_val, K_val);

% Find poles
poles_part2 = roots([1, 1+K_val*Kh_val, K_val]);
fprintf('Closed-loop poles:\n');
for i = 1:length(poles_part2)
    fprintf('  s%d = %.4f %+.4fi\n', i, real(poles_part2(i)), imag(poles_part2(i)));
end
fprintf('\n');

% Calculate damping ratio
wn_part2 = sqrt(K_val);
zeta_part2 = (1 + K_val*Kh_val) / (2*wn_part2);
fprintf('Natural frequency: wn = %.4f rad/s\n', wn_part2);
fprintf('Damping ratio: zeta = %.4f\n\n', zeta_part2);

%% Part (3): K = 1, Kh from 0 to inf (parameter root locus)
fprintf('Part (3): K = 1, vary Kh from 0 to inf (parameter root locus)\n\n');

% Equivalent open-loop for Kh: Geq(s) = s/(s^2+s+1)
num_eq = [1, 0];     % s
den_eq = [1, 1, 1];  % s^2 + s + 1
Geq = tf(num_eq, den_eq);

fprintf('Equivalent open-loop for parameter Kh: Geq(s) = s/(s^2+s+1)\n');
disp(Geq);
fprintf('\n');

figure;
rlocus(Geq);
title('Parameter Root Locus for Kh (K=1, vary Kh from 0 to inf)');
grid on;
saveas(gcf, 'results/figures/Task06_Figure_03.png');
fprintf('Figure 3 saved: Parameter root locus for Kh.\n\n');

%% Part (4): K = 1, Kh = 0, 0.5, 4 - Step response
fprintf('Part (4): Step response metrics for different Kh values\n\n');

K_const = 1;
Kh_list = [0, 0.5, 4];
colors = {'b', 'r', 'g'};

figure;
hold on;
for i = 1:length(Kh_list)
    Kh_i = Kh_list(i);
    num_cl = K_const;
    den_cl = [1, 1+K_const*Kh_i, K_const];
    T_i = tf(num_cl, den_cl);

    [y_i, t_i] = step(T_i);
    plot(t_i, y_i, colors{i}, 'LineWidth', 1.5, ...
        'DisplayName', sprintf('Kh=%.1f', Kh_i));
end
hold off;
xlabel('Time (s)');
ylabel('Amplitude');
title('Step Response for Different Kh Values (K=1)');
legend('show', 'Location', 'southeast');
grid on;
saveas(gcf, 'results/figures/Task06_Figure_04.png');
fprintf('Figure 4 saved: Step responses for different Kh values.\n\n');

% Compute and display metrics
fprintf('Step Response Metrics (K=1):\n');
fprintf('Kh\tOvershoot Mp(%%)\tSettling Time ts(s)\tPeak Time(s)\tRise Time(s)\n');

metrics_table = zeros(length(Kh_list), 4);
for i = 1:length(Kh_list)
    Kh_i = Kh_list(i);
    num_cl = K_const;
    den_cl = [1, 1+K_const*Kh_i, K_const];
    T_i = tf(num_cl, den_cl);

    try
        info_i = stepinfo(T_i);
        metrics_table(i, 1) = info_i.Overshoot;
        metrics_table(i, 2) = info_i.SettlingTime;
        metrics_table(i, 3) = info_i.PeakTime;
        metrics_table(i, 4) = info_i.RiseTime;

        fprintf('%.1f\t%.2f\t\t\t%.4f\t\t\t%.4f\t\t%.4f\n', ...
            Kh_i, info_i.Overshoot, info_i.SettlingTime, ...
            info_i.PeakTime, info_i.RiseTime);
    catch
        fprintf('%.1f\tstepinfo failed for this Kh value\n', Kh_i);
    end
end
fprintf('\n');

% Discussion of Kh effect
fprintf('Discussion on Kh effect on system dynamics:\n');
fprintf('  - When Kh=0 (no derivative feedback), the system is underdamped\n');
fprintf('    with overshoot Mp = %.2f%%.\n', metrics_table(1,1));
fprintf('  - As Kh increases (Kh=%.1f), damping increases significantly,\n', Kh_list(2));
fprintf('    reducing overshoot to Mp = %.2f%%.\n', metrics_table(2,1));
fprintf('  - For Kh=%.1f, the system is heavily damped (or overdamped)\n', Kh_list(3));
fprintf('    with Mp = %.2f%% and longer settling time.\n', metrics_table(3,1));
fprintf('  - Conclusion: Increasing Kh increases the damping ratio,\n');
fprintf('    reduces overshoot, but may increase settling time for large Kh.\n');

fprintf('\nTask 6 completed.\n');
diary off;
