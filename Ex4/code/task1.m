%% Matlab 里控制系统的三种数学模型的转换
clc;
clear;
close all;
diary('results/logs/Task01_output.log');

%% 传递函数模型 tf
disp('传递函数模型 (tf):');
s = tf('s');
G_tf = 20/(s^2 + 2*s - 3);
disp('传递函数 G(s) = 20/(s^2+2s-3):');
G_tf

%% 零极点模型 zpk
disp('零极点模型 (zpk):');
G_zpk = zpk(G_tf);
disp('零极点模型:');
G_zpk

%% 状态空间模型 ss
disp('状态空间模型 (ss):');
G_ss = ss(G_tf);
disp('状态空间模型:');
G_ss

%% 模型转换示例
disp('模型转换示例:');
% 1. 使用 tf2ss 函数: 传递函数 -> 状态空间
disp('1. tf2ss: 传递函数 -> 状态空间');
[num, den] = tfdata(G_tf, 'v');
[A, B, C, D] = tf2ss(num, den);
disp('使用 tf2ss 得到的状态空间矩阵:');
disp('A =');
disp(A);
disp('B =');
disp(B);
disp('C =');
disp(C);
disp('D =');
disp(D);
diary off;
