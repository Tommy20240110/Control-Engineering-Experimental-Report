%% 任务1: 部分分式展开与传递函数
% Example 2-27: Partial fraction expansion using residue()
% Exercise 2-11: Derive transfer functions for 4 op-amp circuits

clc;
clear;
close all;
diary('results/logs/Task01_output.log');

fprintf('Task 1: Partial Fraction and Transfer Function\n\n');

%% 第1部分: 示例2-27 部分分式展开
fprintf('Part 1: Partial Fraction Expansion (Example 2-27)\n\n');

% Define numerator and denominator of G(s)
num = [1, 11, 39, 52, 26];
den = [1, 10, 35, 50, 24];

fprintf('G(s) = (s^4 + 11s^3 + 39s^2 + 52s + 26) / (s^4 + 10s^3 + 35s^2 + 50s + 24)\n\n');

% Use residue() for partial fraction expansion
[r, p, k] = residue(num, den);

fprintf('Partial Fraction Expansion Results:\n');
fprintf('Residues (r):\n');
disp(r');
fprintf('Poles (p):\n');
disp(p');
fprintf('Direct term (k):\n');
disp(k');

fprintf('Expanded form:\n');
for i = 1:length(r)
    if imag(p(i)) == 0
        fprintf('  %.4f / (s + %.4f)\n', r(i), -p(i));
    else
        fprintf('  (%.4f %+.4fi) / (s %+.4f %+.4fi)\n', real(r(i)), imag(r(i)), -real(p(i)), -imag(p(i)));
    end
end
fprintf('\n');

fprintf('\n');

%% 第2部分: 习题2-11 运放电路传递函数
fprintf('Part 2: Op-Amp Transfer Functions (Exercise 2-11)\n\n');

% Define symbolic variables
syms R1 R2 R3 R4 R5 C C1 C2 s

%% Circuit (a): R1 input, R2||C feedback, R3 to ground on non-inverting
fprintf('Circuit (a): Inverting amplifier with R2||C feedback\n');
fprintf('  Input impedance Zi = R1\n');
fprintf('  Feedback impedance Zf = R2 || (1/sC)\n');

% Zf = R2 || (1/sC) = (R2 * (1/sC)) / (R2 + 1/sC) = R2 / (1 + s*R2*C)
Zf_a = R2 / (1 + s*R2*C);
Zi_a = R1;
G_a = -Zf_a / Zi_a;
G_a = simplify(G_a);

fprintf('  G_a(s) = Vo/Vi = -Zf/Zi = \n');
pretty(G_a);
fprintf('\n');

%% Circuit (b): R1 input, (R2 series C) || R4 feedback, R3 to ground
fprintf('Circuit (b): Inverting amplifier with (R2+C) || R4 feedback\n');
fprintf('  Feedback branch: Z1 = R2 + 1/(sC)\n');
fprintf('  Feedback impedance: Zf = Z1 || R4\n');

Z1 = R2 + 1/(s*C);
Zf_b = (Z1 * R4) / (Z1 + R4);
Zi_b = R1;
G_b = -Zf_b / Zi_b;
G_b = simplify(G_b);

fprintf('  G_b(s) = Vo/Vi = -Zf/Zi = \n');
pretty(G_b);
fprintf('\n');

%% Circuit (c): T-network feedback: R2 to node, C from node to GND, R4 from node to output
fprintf('Circuit (c): Inverting amplifier with T-network feedback\n');
fprintf('  Structure: (-)---R2---N---R4---Output, with C from N to GND\n');
fprintf('  Using nodal analysis at node N and virtual ground at (-)\n');

% Define the symbolic transfer function
% From nodal analysis:
% At node N: (0-VN)/R2 + (0-VN)*s*C + (Vo-VN)/R4 = 0
% At (-): Vi/R1 = (0-VN)/R2
% Solving gives: G_c(s) = -(R2+R4)/R1 - s*R2*R4*C/R1

syms VN Vo Vi_node
eq1 = (0 - VN)/R2 + (0 - VN)*s*C + (Vo - VN)/R4 == 0;
eq2 = Vi_node/R1 == (0 - VN)/R2;
sol = solve([eq1, eq2], [VN, Vo]);
G_c = simplify(sol.Vo / Vi_node);

fprintf('  G_c(s) = Vo/Vi = \n');
pretty(G_c);
fprintf('\n');

%% Circuit (d): Complex feedback network
% Structure: (-)---R2---C1---A---R5---Output
%                            |
%                          C2---R4
%                            |
%                           GND
fprintf('Circuit (d): Inverting amplifier with complex feedback network\n');
fprintf('  Structure: (-)---R2---C1---A---R5---Output\n');
fprintf('                      A---C2---R4---GND\n');

% Nodal analysis at node A and virtual ground at (-)
syms VA
% Impedances
Z2 = R2 + 1/(s*C1);  % Series R2 + C1
Z4 = R4 + 1/(s*C2);  % Series R4 + C2

% At node A: current from (-) + current through R5 + current to GND = 0
% (0 - VA)/Z2 + (Vo - VA)/R5 + (0 - VA)/Z4 = 0
eqA = (0 - VA)/Z2 + (Vo - VA)/R5 + (0 - VA)/Z4 == 0;

% At (-) node: Vi/R1 = (0 - VA)/Z2
eqIn = Vi_node/R1 == (0 - VA)/Z2;

sol_d = solve([eqA, eqIn], [VA, Vo]);
G_d = simplify(sol_d.Vo / Vi_node);

fprintf('  G_d(s) = Vo/Vi = \n');
pretty(G_d);
fprintf('\n');

%% Display all transfer functions in a clean summary
fprintf('\nSummary of Transfer Functions:\n\n');
fprintf('G_a(s) = \n'); disp(G_a);
fprintf('G_b(s) = \n'); disp(G_b);
fprintf('G_c(s) = \n'); disp(G_c);
fprintf('G_d(s) = \n'); disp(G_d);

fprintf('\nTask 1 completed.\n');
diary off;
