% Used the Control System Designer to create a Proportional Controller
clear, clc, close all

%% Step 1: Generate Controller, Plant Model
Gc = zpk(-0.2 , 0, 2.25) %zpk(zeros,poles,gain)
Gp = zpk([], [-0.1 -10], 25)

%% Step 2: Open-Loop Function
open_loop = Gc*Gp
% controlSystemDesigner()

%% Step 3: Root Locus Design
figure;
rlocus(open_loop);

%% Step 4: Closed-Loop System
closed_loop = feedback(open_loop, 1,-1);
figure;
step(closed_loop);

%% Closed Loop System Response Info
stepinfo(closed_loop)