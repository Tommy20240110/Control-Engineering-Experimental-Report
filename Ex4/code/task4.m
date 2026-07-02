clc; clear; close all;
diary('results/logs/Task04_output.log');

fprintf('Task 4: Open-Loop Frequency Characteristics with Gain/Phase Margins\n\n');

s = tf('s');

%% 定义系统: G(s) = K / (s(s+1)(s+2))
fprintf('System: G(s) = K / (s(s+1)(s+2))\n\n');

K_vals = [1.5, 15];

for idx = 1:length(K_vals)
    K = K_vals(idx);
    G = K / (s * (s + 1) * (s + 2));
    fprintf('K = %.1f:\n', K);

    % Compute gain margin and phase margin
    [Gm, Pm, Wcg, Wcp] = margin(G);
    Gm_dB = 20 * log10(Gm);
    fprintf('  Gain Margin: %.4f (%.2f dB) at %.4f rad/s\n', Gm, Gm_dB, Wcg);
    fprintf('  Phase Margin: %.4f deg at %.4f rad/s\n\n', Pm, Wcp);

    % Extract frequency response data for manual plotting
    w = logspace(-2, 2, 2000);
    [mag, phase] = bode(G, w);
    mag = squeeze(mag);
    phase = squeeze(phase);
    mag_dB = 20 * log10(mag);

    % Create figure with Bode (magnitude + phase) and Nyquist
    figure('Name', sprintf('Task4_K_%.1f', K), 'Position', [100, 100, 1000, 800]);

    % Magnitude plot
    subplot(2, 2, 1);
    semilogx(w, mag_dB, 'b', 'LineWidth', 1.5);
    grid on;
    xlabel('Frequency (rad/s)');
    ylabel('Magnitude (dB)');
    title(sprintf('Bode Magnitude Plot (K = %.1f)', K));
    hold on;
    % Mark 0 dB line and gain crossover
    xline(Wcp, '--r', sprintf('Wcp = %.2f', Wcp), 'LabelVerticalAlignment', 'bottom');
    yline(0, '--k');
    hold off;

    % Phase plot
    subplot(2, 2, 2);
    semilogx(w, phase, 'r', 'LineWidth', 1.5);
    grid on;
    xlabel('Frequency (rad/s)');
    ylabel('Phase (deg)');
    title(sprintf('Bode Phase Plot (K = %.1f)', K));
    hold on;
    % Mark -180 deg line and phase crossover
    yline(-180, '--k');
    xline(Wcg, '--b', sprintf('Wcg = %.2f', Wcg), 'LabelVerticalAlignment', 'bottom');
    hold off;

    % Nyquist plot
    subplot(2, 2, [3, 4]);
    [re, im] = nyquist(G, w);
    re = squeeze(re);
    im = squeeze(im);
    plot(re, im, 'b', 'LineWidth', 1.5);
    hold on;
    plot(re, -im, 'r--', 'LineWidth', 0.5);  % Mirror for negative frequencies
    plot(-1, 0, 'r+', 'MarkerSize', 15, 'LineWidth', 2);  % Critical point
    xlabel('Real Axis');
    ylabel('Imaginary Axis');
    title(sprintf('Nyquist Diagram (K = %.1f)', K));
    grid on;
    axis equal;
    hold off;

    % Annotate margins on figure
    annotation('textbox', [0.15, 0.02, 0.7, 0.04], 'String', ...
        sprintf('GM = %.2f dB, PM = %.2f deg, Wcg = %.3f rad/s, Wcp = %.3f rad/s', ...
        Gm_dB, Pm, Wcg, Wcp), ...
        'HorizontalAlignment', 'center', 'FontSize', 11, ...
        'EdgeColor', 'k', 'BackgroundColor', 'w');

    % Save figure immediately
    saveas(gcf, sprintf('results/figures/Task04_Figure_%02d.png', idx));

    % Also display Bode using margin() for a clean view
    figure('Name', sprintf('Task4_Margin_K_%.1f', K), 'Position', [200, 200, 800, 600]);
    margin(G);
    grid on;
    saveas(gcf, sprintf('results/figures/Task04_Figure_%02d_margin.png', idx));
end

fprintf('Analysis:\n');
fprintf('  When K = 1.5: System has positive gain margin and phase margin -> stable.\n');
fprintf('  When K = 15: Gain margin decreases, phase margin decreases.\n');
fprintf('  The system becomes less stable as K increases (closer to instability).\n');
fprintf('  Gain margin indicates how much gain can increase before instability.\n');
fprintf('  Phase margin indicates how much phase lag can be added before instability.\n');

diary off;
