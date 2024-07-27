clear;
clc;

%% Import Data & Variables
data = csvread('superconduct.csv');
characteristics = [3 6 9 12];
cluster_rad = [0.2 0.4 0.6 0.8 1]; 
epoch = 100;
epoch_relief = 30;
k = 5;  
grid_score = zeros(length(characteristics), length(cluster_rad));
error = zeros(length(characteristics), length(cluster_rad), k);
iter = 0;

disp('Preprocessing');
[rank, weight] = relieff(data(:, 1:end-1), data(:, end), 20);
[train_data, check_data, valid_data] = split_scale(data, 1);
cross_valid = cvpartition(train_data(:, end), 'KFold', k);


%% 5-fold Cross Validation
for characteristic = 1:length(characteristics)
    for radius = 1:length(cluster_rad)
        for i = 1:k
            iter = iter + 1;
            disp(['Iteration number: ', int2str(iter), ' Characteristics: ', int2str(characteristics(characteristic)), ' Rads: ', num2str(cluster_rad(radius))]);

            training_no = cross_valid.training(i);
            testing_no = cross_valid.test(i);

            % Clustering
            cluster_training_data = data(training_no, rank(1:characteristics(characteristic)));
            cluster_checking_data = data(testing_no, rank(1:characteristics(characteristic)));
            cluster_training_fis = genfis2(cluster_training_data, data(training_no, end), cluster_rad(radius));

            % Training
            [fis, cluster_training_error, ~, cluster_checking_fis, cluster_checking_error] = ...
                anfis(data(training_no, [rank(1:characteristics(characteristic)) end]), cluster_training_fis, ...
                epoch_relief, NaN, data(testing_no, [rank(1:characteristics(characteristic)) end]));

            % RMSE
            error(characteristic, radius, i) = min(cluster_checking_error);
        end

        grid_score(characteristic, radius) = mean(error(characteristic, radius, :));
    end
end

[min_column, min_row] = min(grid_score);
[min_score, min_col] = min(min_column);
min_char_no = min_row(min_col);
min_rad_no = min_col;

%% Train model
fis_training = genfis2(train_data(:, rank(1:characteristics(min_char_no))), train_data(:, end), cluster_rad(min_rad_no));
[fis, train_error, ~, fis_checking, checking_error] = ...
    anfis(train_data(:, [rank(1:characteristics(min_char_no)) end]), fis_training, epoch, NaN, check_data(:, [rank(1:characteristics(min_char_no)) end]));

%% Evaluate model
fis_evaluated = evalfis(valid_data(:, rank(1:characteristics(min_char_no))), fis_checking);

%% Plots
plot_mfs(fis_training, fis_checking);
plot_learning_curve(epoch, train_error, checking_error);
plot_prediction_error(fis_evaluated, valid_data);

% Function Definitions
function plot_mfs(fis_training, fis_checking)
    figure;
    for j = 0:1
        subplot(2, 2, 2*j+1);
        plotmf(fis_training, 'input', j+1);
        title('Pre training');
        subplot(2, 2, 2*j+2);
        plotmf(fis_checking, 'input', j+1);
        title('Post Training');
        grid on;
    end  
end

% Function Definitions
function plot_learning_curve(epoch, train_error, checking_error)
    figure;
    epoch2 = 1:epoch;
    plot(epoch2, train_error .^ 2, 'o-', 'LineWidth', 1, 'Color', 'b');
    hold on;
    plot(epoch2, checking_error .^ 2, 's-', 'LineWidth', 1, 'Color', 'g');
    title('Learning Curve');
    legend('Training Error', 'Validation Error');
    xlabel('Epoch');
    ylabel('Mean Square Error');
    grid on;
end

% Function Definitions
function plot_prediction_error(fis_evaluated, valid_data)
    pred_error = figure('Position', [0 0 6000 450]);
    plot(1:length(fis_evaluated), fis_evaluated, 'b');
    hold on;
    plot(1:length(fis_evaluated), valid_data(:, end), 'g');      
    title('Predictions');
    legend('Predicted Value', 'Real Value');
    grid on;
    saveas(pred_error, strcat('prediction', '.png'));           
    close(pred_error); 
end

%% Calculate and Display Errors
RMSE = sqrt(mean((valid_data(:, end) - fis_evaluated).^2));
disp(['RMSE = ', num2str(RMSE)]);

sy2 = std(valid_data(:, end), 1)^2;
NMSE = (RMSE^2) / sy2;
disp(['NMSE = ', num2str(NMSE)]);

NDEI = sqrt(NMSE);
disp(['NDEI = ', num2str(NDEI)]);

SSres = size(valid_data, 1) * (RMSE^2);
SStot = size(valid_data, 1) * sy2;
R2 = 1 - SSres / SStot;
disp(['R^2 = ', num2str(R2)]);

% Save error metrics to a text file
coefERR = [RMSE NMSE NDEI R2];
dlmwrite('metrics.txt', coefERR);
