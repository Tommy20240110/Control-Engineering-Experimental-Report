clc; clear; close all;
diary('results/logs/Task05_output.log');

fprintf('Task 5: Frequency-Domain Stability Analysis and Optimal Gain\n\n');

s = tf('s');

%% 系统: G(s) = k * (s+1) / (s^2 * (0.1s + 1))
% Base system G0(s) without gain k
G0 = (s + 1) / (s^2 * (0.1*s + 1));
fprintf('Base system: G0(s) = (s+1) / (s^2 * (0.1s + 1))\n');
fprintf('Poles: s = 0 (double), s = -10\n\n');

%% 第一部分: k = 1 时的 Bode 图
fprintf('Part 1: Bode Diagram for k = 1\n');
k1 = 1;
G1 = k1 * G0;

% Compute margins
[Gm, Pm, Wcg, Wcp] = margin(G1);
Gm_dB = 20 * log10(Gm);
fprintf('  k = 1: GM = %.4f (%.2f dB) at %.4f rad/s\n', Gm, Gm_dB, Wcg);
fprintf('        PM = %.4f deg at %.4f rad/s\n\n', Pm, Wcp);

% Figure 1: Bode diagram for k=1
figure('Name', 'Task5_Bode_k1', 'Position', [100, 100, 900, 700]);
margin(G1);
grid on;
title('Bode Diagram for k = 1 with Stability Margins');
saveas(gcf, 'results/figures/Task05_Figure_01.png');

% Frequency-domain stability criterion
fprintf('Frequency-domain stability analysis for k=1:\n');
fprintf('  Open-loop poles: two at origin (marginally stable), one at s=-10 (stable).\n');
fprintf('  Nyquist criterion: For a Type 2 system, check encirclements of -1.\n');
fprintf('  PM = %.2f deg > 0 -> System is closed-loop stable.\n\n', Pm);

%% 第二部分: 寻找最大相位裕度的最优 k
fprintf('Part 2: Optimal Gain for Maximum Phase Margin\n');

% Sweep over a range of frequencies to find the phase characteristic
w = logspace(-2, 2, 10000);
[mag, phase] = bode(G0, w);
mag = squeeze(mag);
phase = squeeze(phase);

% Phase is independent of k
% For a given crossover frequency wc: |k*G0(j*wc)| = 1 => k = 1/|G0(j*wc)|
% PM at wc is: 180 + phase(G0(j*wc))
% We want to find w that maximizes PM

% Since the phase of G0 might not cross -180 (stays above), all k>0 give positive PM
% Maximum PM is at the frequency where phase is maximum (closest to 0)

% Find frequency index where phase is maximum
[max_phase, idx_max] = max(phase);
w_opt = w(idx_max);
k_opt = 1 / mag(idx_max);
PM_max = 180 + max_phase;

fprintf('  Frequency sweep results:\n');
fprintf('  Maximum phase of G0(jw): %.4f deg at w = %.4f rad/s\n', max_phase, w_opt);
fprintf('  |G0(jw_opt)| = %.4f\n', mag(idx_max));
fprintf('  Optimal k = 1/|G0(jw_opt)| = %.4f\n', k_opt);
fprintf('  Maximum phase margin: %.4f deg\n\n', PM_max);

% Figure 2: Phase margin vs k
fprintf('  Computing phase margin for a range of k values...\n');
k_range = logspace(-1, 2, 500);
PM_vals = zeros(size(k_range));
for i = 1:length(k_range)
    % For each k, find the gain crossover frequency and compute PM
    k_i = k_range(i);
    % Gain crossover: |k*G0(jw)| = 1 => |G0(jw)| = 1/k
    target_mag = 1 / k_i;
    % Find frequency where mag is closest to target
    [~, idx_wc] = min(abs(mag - target_mag));
    PM_vals(i) = 180 + phase(idx_wc);
end

[PM_max_found, idx_pm_max] = max(PM_vals);
k_opt_found = k_range(idx_pm_max);
fprintf('  From PM vs k sweep: k_opt = %.4f, max PM = %.4f deg\n\n', k_opt_found, PM_max_found);

figure('Name', 'Task5_PM_vs_k', 'Position', [100, 100, 1000, 400]);

subplot(1, 2, 1);
semilogx(k_range, PM_vals, 'b', 'LineWidth', 1.5);
grid on;
xlabel('Gain k');
ylabel('Phase Margin (deg)');
title('Phase Margin vs Gain k');
hold on;
plot(k_opt_found, PM_max_found, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
text(k_opt_found*1.1, PM_max_found, sprintf('k_{opt} = %.2f\nPM = %.2f deg', k_opt_found, PM_max_found), ...
    'VerticalAlignment', 'bottom');
hold off;

% Figure 3: Bode diagram with optimal k
G_opt = k_opt_found * G0;
subplot(1, 2, 2);
margin(G_opt);
grid on;
title(sprintf('Bode Diagram for Optimal k = %.2f', k_opt_found));
saveas(gcf, 'results/figures/Task05_Figure_02.png');

% Figure 4: Step response comparison for k=1 and k_opt
[Gm_opt, Pm_opt, Wcg_opt, Wcp_opt] = margin(G_opt);
fprintf('  Optimal k = %.4f:\n', k_opt_found);
fprintf('    GM = %.4f (%.2f dB)\n', Gm_opt, 20*log10(Gm_opt));
fprintf('    PM = %.4f deg\n\n', Pm_opt);

% Closed-loop step responses
G_cl1 = feedback(G1, 1);
G_cl_opt = feedback(G_opt, 1);

figure('Name', 'Task5_Step_Response_Comparison', 'Position', [100, 100, 900, 600]);
[y1, t1] = step(G_cl1);
[y2, t2] = step(G_cl_opt);
plot(t1, y1, 'b', 'LineWidth', 1.5);
hold on;
plot(t2, y2, 'r', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Output');
title('Closed-Loop Step Response Comparison');
legend(sprintf('k = 1 (PM = %.1f deg)', Pm), sprintf('k = k_{opt} = %.2f (PM = %.1f deg)', k_opt_found, Pm_opt), ...
       'Location', 'best');
grid on;
hold off;
saveas(gcf, 'results/figures/Task05_Figure_03.png');

%% 分析
fprintf('\nAnalysis:\n');
fprintf('1. The system has two integrators (Type 2), making it conditionally stable.\n');
fprintf('2. For k=1, the system is stable with PM = %.2f deg.\n', Pm);
fprintf('3. The phase of G0(jw) remains above -180 deg for all w.\n');
fprintf('4. Maximum PM = %.2f deg is achieved at k = %.2f.\n', PM_max_found, k_opt_found);
fprintf('5. Beyond the optimal k, PM decreases as the crossover frequency shifts.\n');

diary off;
