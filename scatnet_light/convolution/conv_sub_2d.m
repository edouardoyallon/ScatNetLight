% CONV_SUB_2D Two dimension convolution and downsampling
%
% Usage
%   y_ds = conv_sub_2d(in, filter, ds)
%
% Input 
%   in (numeric) :  fourier transform of the input signal
%   filter (struct) : a filter structure, typically obtained with 
%       a filter bank factory function such as morlet_filter_bank_2d or
%       morlet_filter_bank_2d_pyramid
%   ds (int) : log of downsampling rate
%
% Output
%   y_ds (numeric) : the filtered, downsampled signal, in the spatial domain.
%
% Description
%
% See also
%   MORLET_FILTER_BANK_2D


function y_ds = conv_sub_2d(in, filter, ds)
switch filter.type
    case 'fourier_multires'
        % compute the resolution of the input signal
        res = floor(log2(size(filter.coefft{1},1)/size(in,1)));
        % retrieves the coefficients of the filter for the resolution
        coefft = filter.coefft{res+1};
        % periodization followed by inverse Fourier transform is
        % equivalent to inverse Fourier transform followed by
        % downsampling but is faster because the inverse Fourier
        
        product=bsxfun(@times,in,coefft);
        y_ds=ifft2(periodize_nd_along_k(periodize_nd_along_k(product,2^ds,1),2^ds,2)) / 2^ds;
        
    otherwise
        error('Unsupported filter type.');
end
end

