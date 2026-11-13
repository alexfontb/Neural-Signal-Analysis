function X = delay_coordinates(x, m, tau)
% This function constructs an estimate of the trajectory of the dynamical
% system underlying a scalar time series.
%
% x   : Input EEG signal of length N
% m   : Embedding dimension
% tau : Time delay
% X   : Delay coordinate matrix of size (N-eta) x m

x = x(:);               % ensure column vector for later
N = length(x);          % Length of the time series
eta = (m-1)*tau;        % Embedding window

% check if signal is shorter than embedding window
if N <= eta
    error('Time series too short for given m and tau');
end

M = N - eta;            % Number of states(rows of the output matrix)
X = zeros(M, m);        % preallocate empty matrices

% Matrix Reconstruction
for r = 0:m-1
    % For each r, all rows will take the values of the vector.
    % Build column by column.
    X(:, r+1) = x((eta + 1 - r*tau) : (N - r*tau));
end