% WAVELET_3D
% Compute the wavelet transform of a 3D signal x
%
% Usage:
%   [x_phi, x_psi, meta_phi, meta_psi] = WAVELET_3D(x, filters, options)
%
% Inputs:
%   1.) x (numeric): The input signal, N1xN2xN3, or a tensor N1xN2xN3xM,
%       where M is the number of channels.
%   2.) filters (cell): Cell containing the filters.
%   3.) options (structure): Options of the wavelet transform.
%
% Outputs:
%   1.) x_phi (numeric): Low pass part of the wavelet transform.
%   2.) x_psi (cell): Wavelet coeffcients of the wavelet transform.
%   3.) meta_phi (struct): Meta information associated to x_phi.
%   4.) meta_psi (struct): Meta information assocaited to x_psi.
%
% Description:
%    WAVELET_3D computes a 3D wavelet transform, using the signal and the
%    filters in the Fourier domain. The signal is padded in order to avoid
%    border effects.
%
% See also
%   CONV_SUB_2D, WAVELET_LAYER_1_3D, WAVELET_LAYER_2_3D
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

function [x_phi, x_psi, meta_phi, meta_psi] = wavelet_3d(x, filters, options)

% Initialize options if necessary
if nargin < 3
    options = struct;
end

% Set options
options = fill_struct(options, 'x_resolution', 0);
options = fill_struct(options, 'oversampling', 1);
options = fill_struct(options, 'psi_mask', ...
    ones(1,numel(filters.psi.filter)));
options = fill_struct(options, 'boundary', 'zero');

% Pull out relevant options
x_resolution = options.x_resolution;
oversampling = options.oversampling;
psi_mask = options.psi_mask;
bdry = options.boundary;
switch lower(bdry)
    case {'symm','per'}
        center_sig = false;
    case 'zero'
        center_sig = true;
end

% Padding and Fourier transform
sz_padded = filters.meta.size_filter / 2^x_resolution;
xf = fft3(pad_signal(x, sz_padded, bdry, center_sig));

% Low pass filtering, downsample, unpad
J = filters.phi.meta.J;
ds = max(J - x_resolution - oversampling, 0);
x_phi = real(conv_sub_3d(xf, filters.phi.filter, ds));
x_phi = unpad_signal(x_phi, ds*[1 1 1], size(x), center_sig, [1;2;3]);
meta_phi.j = -1;
meta_phi.axis = [0;0;0];
meta_phi.resolution = x_resolution + ds;

% Band pass filtering, downsample, unpad
num_psi = numel(find(psi_mask));
x_psi = cell(1,num_psi);
meta_psi = struct();
meta_psi.j = zeros(1,num_psi);
meta_psi.axis = zeros(3,num_psi);
for p = find(psi_mask)
    j = filters.psi.meta.j(p);
    ds = max(floor(j) - x_resolution - oversampling, 0);
    x_psi{p} = conv_sub_3d(xf, filters.psi.filter{p}, ds);
    x_psi{p} = unpad_signal(x_psi{p}, ds*[1 1 1], size(x), center_sig, [1;2;3]);
    meta_psi.j(1,p) = filters.psi.meta.j(p);
    meta_psi.axis(:,p) = filters.psi.meta.axis(p);
    meta_psi.resolution(1,p) = options.x_resolution + ds;
end

end