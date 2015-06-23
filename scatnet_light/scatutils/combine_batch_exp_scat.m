% COMBINE_BATCH_EXP_SCAT
% Combines expected scattering output that was computed in several batches.
%
% Usage:
%   EU = COMBINE_BATCH_EXP_SCAT(EU_batch, batch_ind)
%
% Inputs:
%   1.) EU_batch (cell): Each cell EU_batch{i} contains the expected
%       scattering output from a batch of data.
%   2.) batch_ind (cell): The indices of each batch.
%
% Outputs:
%   1.) EU (cell): Expected scattering output of all batches combined.
%
% See also:
%   CREATE_BATCH_IND, EXPECTED_SCAT_LIGHT_2D

function EU = combine_batch_exp_scat(EU_batch, batch_ind)

% Pre-processing
M = length(EU_batch{1});
num_sig = size(EU_batch{1}{1}.signal,1);
EU = cell(1,M);

% Loop through layers and combine
for m=1:M    
    EU{m}.signal = zeros(num_sig, size(EU_batch{1}{m}.signal,2));
    EU{m}.meta = EU_batch{1}{m}.meta;
    for i=1:length(batch_ind)
        EU{m}.signal(batch_ind{i},:) = EU_batch{i}{m}.signal;
    end
end

end