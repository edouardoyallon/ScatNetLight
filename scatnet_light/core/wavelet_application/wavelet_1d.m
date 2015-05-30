% WAVELET_1D One-dimensional wavelet transform
%
% Usages
%    [x_phi, x_psi, meta_phi, meta_psi] = WAVELET_1D(x, filters, options,k)
%
% Input
%    x (numeric): The signal to be transformed. x can be a tensor
%    filters (struct): The filter bank of the wavelet transform.
%    options (struct): Various options for the transform:
%       options.oversampling (int): The oversampling factor (as a power of 2)
%          with respect to the critical bandwidth when calculating convolu-
%          tions (default 1).
%       options.psi_mask (boolean): Specifies the wavelet filters in
%          filters.psi for which the transform is to be calculated (default
%          all).
%       options.x_resolution (int): The resolution of the input signal x as
%          a power of 2, representing the downsampling of the signal with
%          respect to the finest resolution (default 0).
%     k: the dimension along which applying the wavelet transform
%
%
% Output
%    x_phi (numeric): x filtered by the lowpass filter filters.phi.
%    x_psi (cell): cell array of x filtered by the wavelets filters.psi.
%    meta_phi, meta_psi (struct): meta information on x_phi and x_psi, respec-
%       tively.
%
% See also
%    WAVELET_2D

function [x_phi, x_psi, meta_phi, meta_psi] = wavelet_1d(x, filters, options,k)
if nargin < 3
    options = struct();
end

if nargin < 4
    k=1;
end

options = fill_struct(options, 'oversampling', 1);
options = fill_struct(options, ...
    'psi_mask', true(1, numel(filters.psi.filter)));
options = fill_struct(options, 'x_resolution',0);

[~,psi_bw,phi_bw] = filter_freq(filters.meta);

j0 = options.x_resolution;

N_padded_k = filters.meta.size_filter/2^j0;
N_ori=size(x);
N_padded=size(x);
N_padded(k)=N_padded_k;


% NOTE: sped up
to_pad=N_ori(k)~=N_padded(k);

if(to_pad)
    x = pad_signal(x, N_padded, filters.meta.boundary);
end

xf = fft(x,[],k);

ds = round(log2(2*pi/phi_bw)) - j0 - options.oversampling;
ds = max(ds, 0);




% NO REAL !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
x_phi = conv_sub_1d(xf, filters.phi.filter, ds,k);

%N_ori
if(to_pad)
    x_phi = unpad_signal(x_phi, ds, N_ori,[],k);
end

meta_phi.j = -1;
meta_phi.bandwidth = phi_bw;
meta_phi.resolution = j0+ds;


x_psi = {};
meta_psi.j = -1*ones(1, numel(filters.psi.filter));
meta_psi.bandwidth = -1*ones(1, numel(filters.psi.filter));
meta_psi.resolution = -1*ones(1, numel(filters.psi.filter));
for p1 = find(options.psi_mask)
    ds = round(log2(2*pi/psi_bw(p1)/2)) - ...
        j0 - ...
        max(1, options.oversampling);
    ds = max(ds, 0);
    
    x_psi{p1} = conv_sub_1d(xf, filters.psi.filter{p1}, ds,k);
    if(to_pad)
        x_psi{p1} = unpad_signal(x_psi{p1}, ds, N_ori,[],k);
    end
    meta_psi.j(:,p1) = p1-1;
    meta_psi.bandwidth(:,p1) = psi_bw(p1);
    meta_psi.resolution(:,p1) = j0+ds;
end
end
