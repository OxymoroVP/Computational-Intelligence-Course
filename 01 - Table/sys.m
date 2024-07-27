clear, clc, close all

%% PI 
Gc = zpk(-0.2 , 0, 2.25); % Gc = zpk(-c, 0, Kp);
Gp = zpk([], [-0.1 -10], 25);

open_loop = Gc*Gp;
closed_loop = feedback(open_loop, 1,-1);

time = (0:0.01:5)';
u = 50*ones(length(time),1);
y = lsim(closed_loop, u, time);

figure;
lsim(closed_loop, u, time);
stepinfo(y,time)

%% Fuzzy-PI 
fis = create_Fis();
[A,B,C,D] = tf2ss(25, poly([-0.1 -10]));
time = (0:0.01:5)';

ke = 1.1;
k1 = 20;
a = 0.28;
kd = a*ke; 

y_fuzzy = compute(time,[0;0],A,B,C,fis,ke,kd,k1,@input_one);

%% Plot
figure;
plot(time, [y y_fuzzy]);
legend('Classic PI', 'Fuzzy-PI');
title('Classic PI vs Fuzzy-PI controller');
xlabel('Time');

fprintf('PI controller | step-response characteristics: \n')
stepinfo(y, time)

fprintf('FUZZY-PI controller | step-response characteristics: \n')
stepinfo(y_fuzzy, time)

%% Rule stimulation
ruleview(fis);

%% 3D Surface
figure;
gensurf(fis)
title('Output surface of FUZZY-PI');

%% Scenario 2
time = (0:0.01:20);
r2 = input_two_pi(time);
r3 = input_three_pi(time);

y2 = lsim(closed_loop, r2, time);
y3 = lsim(closed_loop, r3, time);

y_fuzzy2 = compute(time,[0;0],A,B,C,fis,ke,kd,k1,@input_two);
y_fuzzy3 = compute(time,[0;0],A,B,C,fis,ke,kd,k1,@input_three);

figure;
plot(time, r2(:), 'b',time, y2(:), 'g', time, y_fuzzy2(:),'r');
title('PI vs Fuzzy-PI controller');
legend('Reference signal', 'PI controller', 'Fuzzy-PI controller');

figure;
plot(time, r3(:), 'b',time, y3(:), 'g', time, y_fuzzy3(:),'r');
title('PI vs Fuzzy-PI controller');
legend('Reference signal', 'PI controller', 'Fuzzy-PI controller');


%% INPUTS
function r = input_one(t)
    r = 50;
end

function r = input_two_pi(time)
r = zeros(length(time),1);
    for i = 1:length(time)
        t = time(i);
        if t<5
            r(i) = 50;
        elseif t>=5 && t<10
            r(i) = 20;
        else
            r(i) = 40;
        end
    end
end

function r = input_two(t)
    if t<5
        r = 50;
    elseif t>=5 && t<10
        r = 20;
    else
        r = 40;
    end
end

function r = input_three_pi(time)
r = zeros(length(time),1);
    for i = 1:length(time)
        t = time(i);
        if t<5
            r(i) = 10*t;
        elseif t>=5 && t<10
            r(i) = 50;
        else
            r(i) = -5*(t-10)+50;
        end
    end
end

function r = input_three(t)
    if t<5
        r = 10*t;
    elseif t>=5 && t<10
        r = 50;
    else
        r = -5*(t-10)+50;
    end
end
