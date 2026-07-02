% 系统稳定性分析
clc;
clear;
close all;
diary('results/logs/Task01_output.log');

%% 1.1 代数法稳定性判据
% 已知开环传递函数 G(s) = 100*(s+3) / [s(s+1)(s+10)].
% 闭环特征多项式 = 1 + G(s) = 0.

% 开环分母展开.
den_open = conv([1 0], conv([1 1], [1 10]));
num_open = 100 * [1 3];

% 将分子补零到与分母相同长度.
n_den = length(den_open);
n_num = length(num_open);
num_open = [zeros(1, n_den - n_num), num_open];

% 闭环特征多项式 = 分母 + 分子.
den_closed = den_open + num_open;

% 方法一: 求分母多项式的根.
roots_closed = roots(den_closed);
disp('代数法稳定性判据:');
disp('方法一: 求分母多项式的根:');
disp(roots_closed);

% 判断稳定性.
if all(real(roots_closed) < 0)
    disp('结论: 闭环系统稳定');
else
    disp('结论: 闭环系统不稳定');
end

% 方法二: Routh 判据.
r = routh(den_closed, 1e-6);
disp('方法二: Routh 函数:');
disp('Routh 表:');
disp(r);
disp('Routh 表第一列:');
disp(r(:, 1));

% 检查第一列是否有符号变化.
first_col = r(:, 1);
sign_changes = 0;
for i = 1:length(first_col) - 1
    if first_col(i) * first_col(i + 1) < 0
        sign_changes = sign_changes + 1;
    end
end
fprintf('Routh 表第一列符号变化次数: %d\n', sign_changes);
if sign_changes == 0 && all(first_col > 0)
    fprintf('结论: 闭环系统稳定\n');
else
    fprintf('结论: 闭环系统不稳定, 有 %d 个右半平面极点\n', sign_changes);
end

%% 1.2 Bode图法判断系统稳定性
% 两个单位负反馈系统的开环传递函数.

% G1(s) = 3 / (s^3 + 5s^2 + 3s)
den_G1 = [1 5 3 0];
num_G1 = [3];

% G2(s) = 3 / (s^3 + 5s^2 - 3s)
den_G2 = [1 5 -3 0];
num_G2 = [3];

disp('Bode图法稳定性判据:');

% 绘制 G1 的 Bode 图
figure(1);
margin(tf(num_G1, den_G1));
title('Bode Plot of G1(s)');
saveas(gcf, 'results/figures/Task01_Figure_01.png');

[Gm1, Pm1, Wcg1, Wcp1] = margin(tf(num_G1, den_G1));
fprintf('\nG1(s): 幅值裕度 = %.2f dB, 相角裕度 = %.2f deg\n', 20*log10(Gm1), Pm1);

if Pm1 > 0 && Gm1 > 1
    fprintf('结论: G1(s) 闭环系统稳定.\n');
else
    fprintf('结论: G1(s) 闭环系统不稳定.\n');
end

% 绘制 G2 的 Bode 图
figure(2);
margin(tf(num_G2, den_G2));
title('Bode Plot of G2(s)');
saveas(gcf, 'results/figures/Task01_Figure_02.png');

[Gm2, Pm2, Wcg2, Wcp2] = margin(tf(num_G2, den_G2));
fprintf('\nG2(s): 幅值裕度 = %.2f dB, 相角裕度 = %.2f deg\n', 20*log10(Gm2), Pm2);

if Pm2 > 0 && Gm2 > 1
    fprintf('结论: G2(s) 闭环系统稳定.\n');
else
    fprintf('结论: G2(s) 闭环系统不稳定.\n');
end

diary off;
disp('Task 1 completed.');

function ra = routh(poli, epsilon)
%   Examples:
%   1) Routh array for s^3 + 2*s^2 + 3*s + 1
%       >> syms EPS
%       >> ra = routh([1 2 3 1], EPS)
%       ra =
%          1.0000    3.0000
%          2.0000    1.0000
%          2.5000         0
%          1.0000         0
%
%   2) Routh array for s^3 + a*s^2 + b*s + c
%       >> syms a b c EPS
%       >> ra = routh([1 a b c], EPS)
%       ra =
%       [          1,          b]
%       [          a,          c]
%       [ (-c + b*a)/a,          0]
%       [          c,          0]
%
%   Author: Rivera-Santos, Edmundo J.
%   E-mail: edmundo@alum.mit.edu

if nargin < 2
    fprintf('\nError: Not enough input arguments given.');
    return;
end

dim = size(poli);               % 获取 poli 的大小.
coeff = dim(2);                 % 获取多项式系数的个数.
ra = zeros(coeff, ceil(coeff / 2));  % 初始化 Routh 数组.

% 组装第 1 行和第 2 行.
for i = 1 : coeff
    ra(2 - rem(i, 2), ceil(i / 2)) = poli(i);
end

rows = coeff - 2;               % 需要计算行列式的行数.
index = zeros(rows, 1);         % 初始化每行列数的索引向量.

% 从底部到顶部形成索引向量.
for i = 1 : rows
    index(rows - i + 1) = ceil(i / 2);
end

% 从第 3 行到最后一行.
for i = 3 : coeff
    if all(ra(i - 1, :) == 0)   % 整行全为零的特殊情况.
        fprintf('\nSpecial Case: Row of zeros detected.');
        a = coeff - i + 2;      % 辅助方程的次数.
        b = ceil(a / 2) - rem(a, 2) + 1;  % 辅助系数的个数.
        temp1 = ra(i - 2, 1 : b);         % 获取辅助多项式.
        temp2 = a : -2 : 0;               % 辅助多项式的幂次.
        ra(i - 1, 1 : b) = temp1 .* temp2; % 辅助多项式的导数.
    elseif ra(i - 1, 1) == 0    % 行首元素为零的特殊情况.
        fprintf('\nSpecial Case: First element is zero.');
        ra(i - 1, 1) = epsilon; % 用 epsilon 替换.
    end

    % 计算 Routh 数组元素.
    for j = 1 : index(i - 2)
        ra(i, j) = -det([ra(i - 2, 1), ra(i - 2, j + 1); ...
            ra(i - 1, 1), ra(i - 1, j + 1)]) / ra(i - 1, 1);
    end
end
end
