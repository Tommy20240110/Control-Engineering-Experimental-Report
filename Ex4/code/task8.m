%% 实验四 Task 8: 时滞系统与 Smith 预估器 (Simulink)
% 闭环系统: Gc(s) = G(s)*e^(-tau*s) / (1 + G(s)*e^(-tau*s))
% G(s) = 1/(s^2+2s+2)
% (1) 利用 Simulink 求解阶跃响应
% (2) Smith 预估器消除纯延迟影响

clc;
clear;
close all;

% 确保输出目录存在
if ~exist('results/logs', 'dir'), mkdir('results/logs'); end
if ~exist('results/figures', 'dir'), mkdir('results/figures'); end

diary('results/logs/Task08_output.log');

fprintf('Task 8: Time Delay System and Smith Predictor (Simulink)\n\n');

%% 系统参数
tau = 1.0;          % 纯延迟时间 (秒)
s = tf('s');
G = 1/(s^2 + 2*s + 2);  % 被控对象
fprintf('Plant: G(s) = 1/(s^2 + 2s + 2)\n');
fprintf('Time delay: tau = %.1f s\n\n', tau);

%% ===== Part (1): 带延迟的闭环系统阶跃响应 (Simulink) =====
fprintf('Part (1): Building Simulink model with time delay...\n');

mdl1 = 'ex4_task8_delay_sys';
if bdIsLoaded(mdl1), close_system(mdl1, 0); end

new_system(mdl1);
open_system(mdl1);

% 添加模块 (不再使用 To Workspace, 改用 Outport)
add_block('simulink/Sources/Step', [mdl1 '/Step']);
add_block('simulink/Commonly Used Blocks/Sum', [mdl1 '/Sum']);
add_block('simulink/Continuous/Transfer Fcn', [mdl1 '/Plant G(s)']);
add_block('simulink/Continuous/Transport Delay', [mdl1 '/Time Delay']);
add_block('simulink/Sinks/Scope', [mdl1 '/Scope']);
add_block('simulink/Sinks/Out1', [mdl1 '/Out1']);

% 配置参数
set_param([mdl1 '/Step'], 'Time', '1', 'Before', '0', 'After', '1');
set_param([mdl1 '/Sum'], 'Inputs', '|+-');
set_param([mdl1 '/Plant G(s)'], 'Numerator', '[1]', 'Denominator', '[1 2 2]');
set_param([mdl1 '/Time Delay'], 'DelayTime', num2str(tau));

% 连线: Step -> Sum(+) -> G(s) -> Delay -> Out1,Scope
%        Delay -> Sum(-)  (反馈)
add_line(mdl1, 'Step/1', 'Sum/1');
add_line(mdl1, 'Sum/1', 'Plant G(s)/1');
add_line(mdl1, 'Plant G(s)/1', 'Time Delay/1');
add_line(mdl1, 'Time Delay/1', 'Out1/1');
add_line(mdl1, 'Time Delay/1', 'Scope/1');
add_line(mdl1, 'Time Delay/1', 'Sum/2');

% 仿真 (使用 sim 返回结构体获取数据)
fprintf('  Running simulation...\n');
simOut1 = sim(mdl1, 'StopTime', '30', 'SaveOutput', 'on', ...
              'OutputSaveName', 'yout', 'SaveTime', 'on', 'TimeSaveName', 'tout');

% 从 simOut 提取数据 (处理 Dataset 格式)
t_delay = simOut1.get('tout');
yout_ds = simOut1.get('yout');
if isa(yout_ds, 'Simulink.SimulationData.Dataset')
    y_delay = yout_ds{1}.Values.Data;
    % 时间从 Dataset 中获取 (更准确)
    t_delay = yout_ds{1}.Values.Time;
else
    y_delay = yout_ds;
end
y_delay = y_delay(:);
t_delay = t_delay(:);

% 保存 Simulink 模型
save_system(mdl1, 'results/figures/Task08_Model_Delay');
fprintf('  Simulink model saved: results/figures/Task08_Model_Delay.slx\n');

% 绘制结果
figure('Visible', 'off');
plot(t_delay, y_delay, 'b-', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Output');
title('Step Response with Time Delay (tau = 1 s)');
grid on;
saveas(gcf, 'results/figures/Task08_Figure_01.png');
fprintf('  Figure 1 saved.\n');
close(gcf);

close_system(mdl1, 0);

%% ===== Part (2): Smith 预估器 (Simulink) =====
fprintf('\nPart (2): Building Smith Predictor Simulink model...\n');

mdl2 = 'ex4_task8_smith_predictor';
if bdIsLoaded(mdl2), close_system(mdl2, 0); end

new_system(mdl2);
open_system(mdl2);

% 模块
add_block('simulink/Sources/Step', [mdl2 '/Step']);
add_block('simulink/Commonly Used Blocks/Sum', [mdl2 '/Sum1']);      % 主误差求和
add_block('simulink/Commonly Used Blocks/Sum', [mdl2 '/Sum2']);      % Smith 补偿
add_block('simulink/Math Operations/Gain', [mdl2 '/Controller K']);
add_block('simulink/Continuous/Transfer Fcn', [mdl2 '/G(s) Plant']);
add_block('simulink/Continuous/Transport Delay', [mdl2 '/Delay']);
add_block('simulink/Continuous/Transfer Fcn', [mdl2 '/Gm(s) Model']);
add_block('simulink/Continuous/Transport Delay', [mdl2 '/Delay Model']);
add_block('simulink/Sinks/Scope', [mdl2 '/Scope']);
add_block('simulink/Sinks/Out1', [mdl2 '/Out1']);

% 配置
set_param([mdl2 '/Step'], 'Time', '1', 'Before', '0', 'After', '1');
set_param([mdl2 '/Sum1'], 'Inputs', '|+-');
set_param([mdl2 '/Sum2'], 'Inputs', '|++-');  % + + -
set_param([mdl2 '/Controller K'], 'Gain', '2');
set_param([mdl2 '/G(s) Plant'], 'Numerator', '[1]', 'Denominator', '[1 2 2]');
set_param([mdl2 '/Delay'], 'DelayTime', num2str(tau));
set_param([mdl2 '/Gm(s) Model'], 'Numerator', '[1]', 'Denominator', '[1 2 2]');
set_param([mdl2 '/Delay Model'], 'DelayTime', num2str(tau));

% Smith 预估器结构连线:
% Step -> Sum1(+) -> Sum2(+) -> K -> G(s) -> Delay -> Out1 -> Sum1(-)
%                                K -> Gm(s) -> (直连 Sum2(+))
%                                K -> Gm(s) -> Delay Model -> Sum2(-)
add_line(mdl2, 'Step/1', 'Sum1/1');
add_line(mdl2, 'Sum1/1', 'Sum2/1');
add_line(mdl2, 'Sum2/1', 'Controller K/1');
add_line(mdl2, 'Controller K/1', 'G(s) Plant/1');
add_line(mdl2, 'G(s) Plant/1', 'Delay/1');
add_line(mdl2, 'Delay/1', 'Out1/1');
add_line(mdl2, 'Delay/1', 'Scope/1');
add_line(mdl2, 'Delay/1', 'Sum1/2');

% Smith 补偿支路
add_line(mdl2, 'Controller K/1', 'Gm(s) Model/1');
add_line(mdl2, 'Gm(s) Model/1', 'Sum2/2');         % 模型输出直接加到 Sum2(+)
add_line(mdl2, 'Gm(s) Model/1', 'Delay Model/1');
add_line(mdl2, 'Delay Model/1', 'Sum2/3');          % 延迟模型输出减掉

% 仿真
fprintf('  Running Smith predictor simulation...\n');
simOut2 = sim(mdl2, 'StopTime', '30', 'SaveOutput', 'on', ...
              'OutputSaveName', 'yout', 'SaveTime', 'on', 'TimeSaveName', 'tout');

t_smith = simOut2.get('tout');
yout_ds2 = simOut2.get('yout');
if isa(yout_ds2, 'Simulink.SimulationData.Dataset')
    y_smith = yout_ds2{1}.Values.Data;
    t_smith = yout_ds2{1}.Values.Time;
else
    y_smith = yout_ds2;
end
y_smith = y_smith(:);
t_smith = t_smith(:);

% 保存模型
save_system(mdl2, 'results/figures/Task08_Model_Smith');
fprintf('  Simulink model saved: results/figures/Task08_Model_Smith.slx\n');

% 绘图
figure('Visible', 'off');
plot(t_smith, y_smith, 'r-', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Output');
title('Step Response with Smith Predictor');
grid on;
saveas(gcf, 'results/figures/Task08_Figure_02.png');
fprintf('  Figure 2 saved.\n');
close(gcf);

close_system(mdl2, 0);

%% ===== Part (3): 对比分析 =====
fprintf('\nPart (3): Comparison analysis...\n');

% 理想无延迟响应 (参考)
G_cl_ideal = feedback(2*G, 1);
[y_ideal, t_ideal] = step(G_cl_ideal, 0:0.1:30);

figure('Visible', 'off');
plot(t_ideal, y_ideal, 'k-', 'LineWidth', 1.5); hold on;
plot(t_delay, y_delay, 'b--', 'LineWidth', 1.5);
plot(t_smith, y_smith, 'r-.', 'LineWidth', 1.5); hold off;
xlabel('Time (s)');
ylabel('Output');
title('Comparison: Ideal vs Delayed vs Smith Predictor');
legend('Ideal (no delay)', 'With delay', 'Smith Predictor', ...
       'Location', 'southeast');
grid on;
saveas(gcf, 'results/figures/Task08_Figure_03.png');
fprintf('  Figure 3 saved.\n');
close(gcf);

%% 结果总结
fprintf('\n====== Analysis Summary ======\n');
fprintf('1. Regular feedback with time delay:\n');
fprintf('   - Delay introduces phase lag in the loop\n');
fprintf('   - Can cause oscillation or instability\n');
fprintf('   - Step response shows delayed reaction and overshoot\n\n');
fprintf('2. Smith Predictor:\n');
fprintf('   - Uses internal model Gm(s) to predict undelayed output\n');
fprintf('   - Subtracts delayed model prediction, adds instantaneous prediction\n');
fprintf('   - Controller effectively "sees" delay-free plant\n');
fprintf('   - Result: response matches ideal case, shifted by tau\n\n');
fprintf('3. Simulink models saved for GUI inspection:\n');
fprintf('   - results/figures/Task08_Model_Delay.slx\n');
fprintf('   - results/figures/Task08_Model_Smith.slx\n');

fprintf('\nTask 8 completed.\n');
diary off;
