% CREATE_BATCH_IND
% Creates batch indices for computing the scattering transform in batch.
% Can also return the data set broken up into the batches.
%
% Usage:
%   batch_ind = CREATE_BATCH_IND(num_per_batch, total_num)
%   batch_ind = CREATE_BATCH_IND(num_per_batch, total_num, X)
%
% Inputs:
%   1.) num_per_batch (numeric): Number data points per batch.
%   2.) total_num (numeric): Total number of data points.
%   3.) X (numeric): 2D data set of size N1xN2xtotal_num.
%
% Outputs:
%   1.) batch_ind (cell): 1xM cell where M is the number of batches. Each
%       cell contains the indices of the batch.

function [batch_ind, X_batch] = create_batch_ind(num_per_batch, total_num, X)

% Create indices
num_batch = ceil(total_num/num_per_batch);
batch_ind = cell(1,num_batch);
for i=1:num_batch
    batch_ind{i} = (num_per_batch*(i-1)+1:min(num_per_batch*i,total_num));
end

% Partition data if inputted
if nargin > 2 && nargout > 1
    X_batch = cell(1,num_batch);
    for i=1:num_batch
        X_batch{i} = X(:,:,batch_ind{i});
    end
end

end