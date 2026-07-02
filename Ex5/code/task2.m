% System Controllability and Observability Analysis
clc;
clear;
close all;
diary('results/logs/Task02_output.log');

fprintf('Task 2: System Controllability and Observability Analysis\n');
fprintf('Transfer function: G(s) = (s + a) / (s^3 + 10s^2 + 27s + 8)\n');
fprintf('a = -2, 0, +2\n\n');

a_values = [-2, 0, 2];
n = 3;  % system order

% 存储结果用于汇总.
results_data = [];

for idx = 1:length(a_values)
    a = a_values(idx);
    fprintf('a = %d:\n', a);

    % Numerator and denominator
    num = [1, a];
    den = [1, 10, 27, 8];

    % Convert to state-space using tf2ss (controller canonical form)
    [A, B, C, D] = tf2ss(num, den);

    fprintf('State-space representation (controller canonical form):\n');
    fprintf('A =\n');
    disp(A);
    fprintf('B =\n');
    disp(B);
    fprintf('C =\n');
    disp(C);
    fprintf('D = %d\n', D);

    %% 可控性分析
    Co = ctrb(A, B);
    rank_Co = rank(Co);
    fprintf('Controllability matrix Co =\n');
    disp(Co);
    fprintf('Rank(Co) = %d (system order n = %d)\n', rank_Co, n);

    if rank_Co == n
        fprintf('>> System is CONTROLLABLE.\n');
        controllable = true;
    else
        fprintf('>> System is NOT CONTROLLABLE.\n');
        controllable = false;
    end

    %% 可观性分析
    Ob = obsv(A, C);
    rank_Ob = rank(Ob);
    fprintf('\nObservability matrix Ob =\n');
    disp(Ob);
    fprintf('Rank(Ob) = %d (system order n = %d)\n', rank_Ob, n);

    if rank_Ob == n
        fprintf('>> System is OBSERVABLE.\n');
        observable = true;
    else
        fprintf('>> System is NOT OBSERVABLE.\n');
        observable = false;
    end

    %% Gramian 验证
    fprintf('\nGramian Verification:\n');
    sys = ss(A, B, C, D);
    poles = eig(A);
    fprintf('System poles: ');
    fprintf('%.4f  ', real(poles));
    fprintf('\n');

    if all(real(poles) < -1e-10)
        try
            Wc = gram(sys, 'c');
            Wo = gram(sys, 'o');
            fprintf('Controllability Gramian Wc =\n');
            disp(Wc);
            fprintf('Observability Gramian Wo =\n');
            disp(Wo);

            % Rank from SVD of Gramians
            sv_Wc = svd(Wc);
            sv_Wo = svd(Wo);
            fprintf('Singular values of Wc: ');
            fprintf('%.6e  ', sv_Wc);
            fprintf('\n');
            fprintf('Singular values of Wo: ');
            fprintf('%.6e  ', sv_Wo);
            fprintf('\n');

            rank_Wc = rank(Wc, 1e-6);
            rank_Wo = rank(Wo, 1e-6);
            fprintf('Rank(Wc) = %d, Rank(Wo) = %d\n', rank_Wc, rank_Wo);

            if rank_Wc == n
                fprintf('Gramian verification: CONTROLLABLE.\n');
            else
                fprintf('Gramian verification: NOT CONTROLLABLE.\n');
            end
            if rank_Wo == n
                fprintf('Gramian verification: OBSERVABLE.\n');
            else
                fprintf('Gramian verification: NOT OBSERVABLE.\n');
            end
        catch ME
            fprintf('Gramian computation failed: %s\n', ME.message);
        end
    else
        fprintf('System has non-negative real poles; gramian computation skipped.\n');
    end

    % Store for summary
    results_data = [results_data; a, rank_Co, rank_Ob, controllable, observable];
    fprintf('\n');
end

%% 结果汇总表
fprintf('SUMMARY OF RESULTS\n');
fprintf('  a   | rank(Co) | rank(Ob) | Controllable | Observable\n');
fprintf('------+----------+----------+--------------+------------\n');
for i = 1:size(results_data, 1)
    c_str = 'Yes';
    o_str = 'Yes';
    if results_data(i, 4) == 0
        c_str = 'No';
    end
    if results_data(i, 5) == 0
        o_str = 'No';
    end
    fprintf('  %2d  |    %d     |    %d     |     %s       |    %s\n', ...
        results_data(i, 1), results_data(i, 2), results_data(i, 3), c_str, o_str);
end
fprintf('Note: System order n = %d. Full rank (n) means controllable/observable.\n\n', n);

%% 零极点图
figure(1);
for idx = 1:length(a_values)
    a = a_values(idx);
    subplot(1, 3, idx);
    sys_tf = tf([1, a], [1, 10, 27, 8]);
    pzmap(sys_tf);
    title(sprintf('Pole-Zero Map (a = %d)', a));
    xlabel('Real Axis');
    ylabel('Imaginary Axis');
    grid on;
    [p, z] = pzmap(sys_tf);
    text_x = xlim;
    text_y = ylim;
    if ~isempty(z)
        text(text_x(1)+0.1*(text_x(2)-text_x(1)), text_y(2)-0.1*(text_y(2)-text_y(1)), ...
            sprintf('Zero: %.2f', real(z(1))), 'FontSize', 9);
    end
end
sgtitle('Pole-Zero Maps for Different a Values');
saveas(gcf, 'results/figures/Task02_Figure_01.png');
fprintf('Figure 1 saved: Task02_Figure_01.png (Pole-Zero Maps)\n');

%% 阶跃响应对比
figure(2);
hold on;
colors = {'b', 'r', 'g'};
for idx = 1:length(a_values)
    a = a_values(idx);
    sys_tf = tf([1, a], [1, 10, 27, 8]);
    step(sys_tf, 10);
end
hold off;
title('Step Response Comparison');
xlabel('Time (seconds)');
ylabel('Amplitude');
legend('a = -2', 'a = 0', 'a = +2', 'Location', 'best');
grid on;
saveas(gcf, 'results/figures/Task02_Figure_02.png');
fprintf('Figure 2 saved: Task02_Figure_02.png (Step Response Comparison)\n');

%% Bode 图对比
figure(3);
hold on;
for idx = 1:length(a_values)
    a = a_values(idx);
    sys_tf = tf([1, a], [1, 10, 27, 8]);
    bode(sys_tf);
    hold on;
end
hold off;
title('Bode Diagram Comparison for Different a Values');
legend('a = -2', 'a = 0', 'a = +2', 'Location', 'southwest');
grid on;
saveas(gcf, 'results/figures/Task02_Figure_03.png');
fprintf('Figure 3 saved: Task02_Figure_03.png (Bode Diagram Comparison)\n');

fprintf('\nTask 2 completed successfully.\n');
diary off;
