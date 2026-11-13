function NN = nearest_neighbors(D,k)
% This function finds the k nearest states in the reconstructed space.
% Takes the distance matrix and returns the indices of the k states with
% minimum Euclidean distance to each reference state. 
% 
% D : Distance Matrix (M x M). M = (N-eta).
% k : Number of nearest neighbors to get.
% NN : Nearest Neighbors matrix. Row i contains indices of k nearest neighbor
% to state i.

[~,idx_sorted]=sort(D,2);   % Sort each row of matrix D in ascending order
NN = idx_sorted(:,1:k);     % Extract the k smallest distance values.
end