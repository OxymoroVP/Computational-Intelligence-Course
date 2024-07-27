clear;
clc;

%% Import Data
try
    data = importdata('airfoil_self_noise.dat');
catch
    error('Error importing data.');
end

% Split data (60% training, 20% validation, 20% test)
[training_data, validation_data, test_data] = split_scale(data, 1);

%% Create Models
epochs = 200;

% TSK Model A-B-C-D
tsk_a = genfis1(training_data, 2, 'gbellmf', 'constant');
tsk_b = genfis1(training_data, 3, 'gbellmf', 'constant');
tsk_c = genfis1(training_data, 2, 'gbellmf', 'linear');
tsk_d = genfis1(training_data, 3, 'gbellmf', 'linear');

%% Train models
try
    [tsk_a, train_error_a, ~, chkFIS_a, cv_error_a] = anfis(training_data, tsk_a, epochs, NaN, validation_data);
    [tsk_b, train_error_b, ~, chkFIS_b, cv_error_b] = anfis(training_data, tsk_b, epochs, NaN, validation_data);
    [tsk_c, train_error_c, ~, chkFIS_c, cv_error_c] = anfis(training_data, tsk_c, epochs, NaN, validation_data);
    [tsk_d, train_error_d, ~, chkFIS_d, cv_error_d] = anfis(training_data, tsk_d, epochs, NaN, validation_data);
catch
    error('Error during model training.');
end

%% Evaluate models
eval_tsk_a = evalfis(test_data(:, 1:end-1), tsk_a);
eval_tsk_b = evalfis(test_data(:, 1:end-1), tsk_b);
eval_tsk_c = evalfis(test_data(:, 1:end-1), tsk_c);
eval_tsk_d = evalfis(test_data(:, 1:end-1), tsk_d);

%% Plots
%% Membership Functions
plot_mfs(tsk_a, 'TSK Model 1');
plot_mfs(tsk_b, 'TSK Model 2');
plot_mfs(tsk_c, 'TSK Model 3');
plot_mfs(tsk_d, 'TSK Model 4');

% Function Definitions
function plot_mfs(model, model_name)
    % Plot membership functions for a given model
    figure('Position', [0 0 500 1000]);
    for k = 1:5
        subplot(5, 1, k);
        plotmf(model, 'input', k);
        title(['Membership Functions - ' model_name]);
        ylabel('Degrees');
        grid on;
    end
end

%% Learning Curves 
plot_learning_curve(train_error_a, cv_error_a, 'TSK Model 1');
plot_learning_curve(train_error_b, cv_error_b, 'TSK Model 2');
plot_learning_curve(train_error_c, cv_error_c, 'TSK Model 3');
plot_learning_curve(train_error_d, cv_error_d, 'TSK Model 4');

% Function Definitions
function plot_learning_curve(train_error, cv_error, model_name)
    % Plot learning curve
    figure;
    plot(1:length(train_error), train_error, 'b-', 'LineWidth', 1); 
    hold on;
    plot(1:length(cv_error), cv_error, 'g-', 'LineWidth', 1);
    title(['Learning Curve - ' model_name]);
    legend('Training Error', 'Cross Validation Error');
    xlabel('Epochs');
    ylabel('Error');
    grid on;
end

%% Prediction Error & Metrics
plot_prediction_error(eval_tsk_a, test_data, 'TSK Model 1');
plot_prediction_error(eval_tsk_b, test_data, 'TSK Model 2');
plot_prediction_error(eval_tsk_c, test_data, 'TSK Model 3');
plot_prediction_error(eval_tsk_d, test_data, 'TSK Model 4');

% Function Definitions
function plot_prediction_error(eval_model, test_data, model_name)
    % Plot prediction error
    figure;
    plot(1:length(eval_model), eval_model, 'Color', 'b');
    hold on;
    plot(1:length(eval_model), test_data(:, end), 'Color', 'g');
    title(['Predictions - ' model_name]);
    legend('Predicted Value', 'Real Value');
    xlabel('Sample');
    ylabel('Value');
    grid on;

    % Calculate metrics
    RMSE = sqrt(mean((test_data(:, end) - eval_model).^2));
    sy2 = std(test_data(:, end), 1)^2;
    NMSE = (RMSE^2) / sy2;
    NDEI = sqrt(NMSE);
    SSres = length(test_data) * (RMSE^2);
    SStot = length(test_data) * sy2;
    R2 = 1 - SSres / SStot;
    error_txt = [RMSE, NMSE, NDEI, R2];
    dlmwrite(['error metrics_' model_name '.txt'], error_txt);
end
