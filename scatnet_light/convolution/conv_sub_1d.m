% CONV_SUB_1D One-dimensional convolution and downsampling.
%
% Usage
%    y_ds = CONV_SUB_1D(xf, filter, ds, k)
%
% Input
%    xf (numeric): The Fourier transform of the signal to be convolved.
%    filter (*struct*): The analysis filter in the frequency
%       domain. Either Fourier transform of the filter or the output of
%       OPTIMIZE_FILTER.
%    ds (int): The downsampling factor as a power of 2 with respect to xf.
%    k (int): dimension along we need to convolve
%
% Output
%    y_ds (numeric): the filtered, downsampled signal, in the time domain.
%
% Description
%    This function performs a convolution via a multiresolution filterbank.
%    No up-sampling is performed.
%
% See also
%   CONV_SUB_2D

function y_ds = conv_sub_1d(xf, filter, ds, k)
sig_length = size(xf,k);

if isstruct(filter)
    % optimized filter, output of OPTIMIZE_FILTER
    if strcmp(filter.type,'fourier_multires')
        s=ones(1,k-1);
        s(end+1)=numel(filter.coefft{1+log2(filter.N/sig_length)});
        filt=reshape(filter.coefft{1+log2(filter.N/sig_length)},s);
        yf=bsxfun(@times,xf,filt);
    else
        error('Unsupported filter type');
    end
else
    error('Unsupported filter type');
end

% calculate the downsampling factor with respect to yf
dsj = ds+log2(size(yf,k)/sig_length);
if dsj > 0
    % actually downsample, so periodize in Fourier
    yf_ds = periodize_nd_along_k(yf,2^dsj,k);%reshape( ...
elseif dsj < 0
   error('This line should never be reached.')
    
else
    yf_ds = yf;
end

y_ds = ifft(yf_ds,[],k)/2^(ds/2);
end
