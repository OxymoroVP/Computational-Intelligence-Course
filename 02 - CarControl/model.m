clear, clc, close all

%% Initialize environment 
x_coords = [0 10.2];
y_coords = [0 4.2];
walls = [5 0 ; 5 1 ; 6 1 ; 6 2 ; 7 2 ; 7 3 ; 10 3]; 
angles = [0 -45 -90];
speed = 0.05;
target = [10; 3.2];
fis = createFis();

%% Simulation
for i=1:length(angles)
    pos = [4.1; 0.3];
    theta = angles(i);
    j=1;
    N=1000;
    while j<N
        
        [dh, dv] = getSensorData(pos(:,end));
        
        if(dh==0 || dv==0)
            fprintf("\nHIT WALL at (%.01f, %.01f) at step %d\n", pos(1,end), pos(2,end), j);
            break;
        end
        delta_theta = evalfis(fis, [dv, dh, theta(end)]);
        theta = [theta theta(end)+delta_theta];
        pos = [pos pos(:,end) + [cosd(theta(end)); sind(theta(end))] * speed];

        distance_from_target = sqrt(sumsqr([pos(1,end) - target(1); pos(2,end) - target(2)]));

        limit_exceeded = (pos(1,end) < x_coords(1) || pos(1,end)> x_coords(2))...
            || (pos(2,end) < y_coords(1) || pos(2,end) > y_coords(2));

        if(distance_from_target < 0.2)
            fprintf("REACHED TARGET at (%.01f,%.01f)\n", pos(1,end), pos(2,end));
            break;
        elseif(limit_exceeded)
            fprintf("LIMIT EXCEEDED AT (%.01f,%.01f)\n", pos(1,end), pos(2,end));
            break;
        end
        j = j + 1;
    end
    
    figure();
    titleStr = sprintf('Launching with %d°', angles(i));
    title(titleStr);
    grid on;
    hold on;
    plot(4.1, 0.3, '.', 'MarkerSize', 16, 'Color',"r");
    plot(pos(1,:),pos(2,:), 'Color', 'r', 'LineStyle', '-.', 'LineWidth', 1);
    plot(target(1), target(2), "x", 'MarkerSize', 16, 'Color', 'k');
    a = area(walls(:,1), walls(:,2), 'DisplayName','Walls');
    set(a, 'FaceColor', [.7 .7 .7]);
end
