% PERIODIZE_FILTER_3D 
% Periodizes filter at multiple resolutions
%
% Usage:
%    filter = PERIODIZE_FILTER_3D(filter_f)
%
% Input:
%   1.) filter_f (numeric): The Fourier representation of the filter.
%
% Output:
%   1.) filter (struct): The periodized multi-resolution representation of
%       the filter. See description for more details.
%
% Description:
%   By periodizing the Fourier transform, which corresponds to subsampling
%   in time, representations of the filter at different resolutions are
%   pre-computed, computation is sped during convolutions.
%
%   The output filter contains the fields: 
%       a.) filter.type (char): Fixed to 'fourier_multires'.
%       b.) filter.N (int): The original size of the filter.
%       c.) filter.coefft (cell): A cell array Fourier representations, 
%           with filter.coefft{j0+1} corresponding to the resolution 
%           N/2^j0.
%       d.) filter.resolution (numeric): The list of resolutions of each
%           filter.
%
% Note:
%     This is an approximate periodization that relies on the fact that the
%     energy is compactly supported.
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

function filter = periodize_filter_3d(filter_f)

% Size of full resolution filter
N = size(filter_f);
N = N(N>1);

% Initialize multiresolution filter
filter.type = 'fourier_multires';
filter.N = N;
filter.coefft = {};
filter.resolution = [];

% Loop through resolutions
j0 = 0;
while 1
    
    % Stopping condition
    if any(abs(floor(N./2^(j0+1))-N./2^(j0+1))>1e-6)
        break;
    end
    
    % 1D, 2D, or 3D sizes
    switch length(N)
        case 1
            sz_in = [N/2^j0 2^j0 1 1];
            sz_out = [N/2^j0 1];
        case 2
            sz_in = [N(1)/2^j0 2^j0 N(2)/2^j0 2^j0];
            sz_out = N./2^j0;
        case 3
            sz_in = [N(1)/2^j0 2^j0 N(2)/2^j0 2^j0 N(3)/2^j0 2^j0];
            sz_out = N./2^j0;
    end
   
    % Get central part of filter over correct period
    filter_fj = filter_f;
    for d = 1:length(N)
        mask = [ones(N(d)/2^(j0+1),1); 1/2; zeros((1-2^(-j0-1))*N(d)-1,1)] + ...
            [zeros((1-2^(-j0-1))*N(d),1); 1/2; ones(N(d)/2^(j0+1)-1,1)];
        if d > 1
            mask = permute(mask,[d 2:d-1 1 d+1:ndims(mask)]);
        end
        filter_fj = bsxfun(@times, filter_fj, mask);
    end
    
    % Periodize filter
    if length(N) < 3
        filter.coefft{j0+1} = reshape( ...
            sum(sum(reshape(filter_fj,sz_in),2),4),sz_out);
    else
        filter.coefft{j0+1} = reshape(sum(sum(sum(reshape(...
            filter_fj,sz_in),2),4),6),sz_out);
    end
    
    % Next resolution
    filter.resolution(j0+1) = j0;
    j0 = j0+1;
    
end

% Oversampling = -1 case
filter.coefft{j0+1} = 1;
filter.resolution(j0+1) = j0;

end