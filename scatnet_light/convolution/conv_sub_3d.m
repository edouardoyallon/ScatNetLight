% CONV_SUB_3D
% Three dimensional convolution (computed as a product in frequency) and
% downsampling
%
% Usage:
%   y_ds = CONV_SUB_3D(in, filter, ds)
%
% Inputs:
%   1.) in (numeric): Fourier transform of the input signal.
%   2.) filter (struct): A filter structure, as obtained from
%       MORLET_FILTER_BANK_3D.
%   3.) ds (int): Log2 of downsampling rate.
%
% Outputs:
%   1.) y_ds (numeric): The filtered, downsampled signal, in the spatial
%       domain.
%
% See also:
%   MORLET_FILTER_BANK_3D
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

function y_ds = conv_sub_3d(in, filter, ds)

switch lower(filter.type)
    
    case 'fourier_multires'
        
        % Compute the resolution of the input signal
        res = floor(log2(size(filter.coefft{1},1)/size(in,1)));
        
        % Retrieve the coefficients of the filter at the right resolution
        coefft = filter.coefft{res+1};
        
        % Periodization followed by inverse FFT (equivalent to inverse FFT
        % followed by downsampling but this way is faster)
        product = bsxfun(@times, in, coefft);
        y_ds = ifft3(periodize_nd_along_k(...
            periodize_nd_along_k(...
            periodize_nd_along_k(product, 2^ds, 1), 2^ds, 2), 2^ds, 3)) / 2^ds;
        
    otherwise
        error('Unsupported filter type.');
    
end

end