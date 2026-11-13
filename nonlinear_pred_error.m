function prediction_error = nonlinear_pred_error (eeg,neighbour,prediction_horizon,nu)
   N=size(neighbour,1); % cogemos el numero de filas de la matriz neighbours
   errors= zeros(N-prediction_horizon,1); % una columna de valores de error ara cada fila de neighbours

   %calcular el prediction error.
   for i= 1:(N-prediction_horizon)
       idx_neigh= neighbour(i,:); % from te matrix of the nearest neighbours
       idx_neigh = idx_neigh(isfinite(idx_neigh));

       idx_future= idx_neigh+ nu+ prediction_horizon; %index of the future
       % Filtrar vecinos válidos 
       valid = idx_future >= 1 & idx_future <= length(eeg); 
       idx_future = idx_future(valid);

       predicted_value= mean(eeg(idx_future)); %value of the future index and mean with nearest neighbours (estimate)

       real_value= eeg(i+nu+prediction_horizon); % real future value

       errors(i)= (predicted_value-real_value)^2; % we fill the column vector of error

   end

    prediction_error= sqrt(mean(errors));

end






