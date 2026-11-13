function NPE = nonlinear_pred_error2(x, m, tau, tc, k, h)
% This function commputes the Nonlinear Prediction Error.
%
% x   : 1D input signal (must be already normalized)
% m   : Embedding dimension
% tau : Time delay
% tc  : Theiler Correction window
% k   : Number of nearest neighbors
% h   : Prediction horizon

% 1. Setup and Preallocation
x = x(:);               % Ensure column vector
nu = (m-1)*tau;         % Embedding window (Fixed: previously was *k)

% 2. State Space Reconstruction & Distance Computation
X = delay_coordinates(x, m, tau);   % Compute delay coordinates matrix
D = distance_matrix_fast(X, tc, h);         % Compute distance matrix
NN = nearest_neighbors(D, k);       % Extract nearest neighbors

valid_states = size(NN, 1);        % Number of states (M = N - eta)
errors = zeros(valid_states, 1); % Preallocate errors (up to M-h to avoid index out of bounds)

% 3. Final Prediction Error Computation
for i = 1:valid_states
    idx_neigh = NN(i,:);
    idx_neigh = idx_neigh(isfinite(idx_neigh)); % Safety check

    idx_future = idx_neigh + nu + h; % Future index in the original signal

    % If no valid neighbors exist for this point, skip
    if isempty(idx_future)
        continue;
    end

    % The predicted value is the avg of all nearest neighbors in the future
    predicted_value = mean(x(idx_future));
    real_value = x(i + nu + h); % Real future value

    errors(i) = (predicted_value - real_value)^2; % Squared error
end

NPE = sqrt(mean(errors));
end