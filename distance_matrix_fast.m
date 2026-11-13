function D = distance_matrix_fast(X, Tw, h)
    % Number of valid states that can actually project 'h' steps into the future
    M_valid = size(X, 1) - h; 
    
    % Keep only the valid states for both references (rows) and neighbors (columns)
    X_valid = X(1:M_valid, :);
    
    % 1. Compute distances using pdist2
    D = pdist2(X_valid, X_valid); 
    
    % 2. Create the Theiler mask using your elegant implicit expansion
    mask = abs((1:M_valid)' - (1:M_valid)) <= Tw; 
    
    % 3. Apply the Theiler correction
    D(mask) = inf; 
end