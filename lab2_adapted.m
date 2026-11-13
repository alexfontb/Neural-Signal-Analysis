eeg = load('EEG4.mat');
data = eeg.EEG; 
xx = data(1:4000,1); 

% Normalize the data
xx1 = (xx - mean(xx)) / std(xx);

num_neighbours = 3;
taus = 1:3:49;
prediction_errors = zeros(length(taus),1);
m = 6;
Theiler = 30;
horizon = 2;

i = 0; 
% Loop for different tau values
for tau_val = taus % Changed variable name to tau_val to avoid confusion with k neighbors
    i = i + 1;
    % All steps unified in one function!
    prediction_errors(i) = nonlinear_pred_error2(xx1, m, tau_val, Theiler, num_neighbours, horizon);
    disp(['Calculated for tau = ', num2str(tau_val)]);
end

% Plot
figure;
plot(taus, prediction_errors)
title('Tau vs Prediction error')
xlabel('Tau'); 
ylabel('Prediction error');

% Distance matrix plot for optimal tau (tau = 19)
X = delay_coordinates(xx1, 6, 19); 
D = distance_matrix(X, 30);
figure; imagesc(D);  
colormap(jet); 
axis square; 
title('Distance Matrix for optimal tau (\tau = 19)'); 
xlabel('State index'); 
ylabel('State index');