
% WAVELET_2D Compute the wavelet transform of a signal x
%
% Usage
%    [x_2j] = WAVELET_2D(x, filters, options)
%
% Input
%    x (numeric): the input signal ; x can be a tensor, the output will be
%    a tensor of the same size
%    filters (cell): cell containing the filters
%    options (structure): options of the wavelet transform
%
% Output
%    x_phi (numeric): Low pass part of the wavelet transform
%    x_psi (cell): Wavelet coeffcients of the wavelet transform
%    meta_phi (struct): meta associated to x_phi
%    meta_psi (struct): meta assocaited to y_phi
%
% Description
%    WAVELET_2D computes a wavelet transform, using the signal and the
%    filters in the Fourier domain. The signal is padded in order to avoid
%    border effects.
%
%    The meta information concerning the signal x_phi, x_psi(scale, angle,
%    resolution) can be found in meta_phi and meta_psi.
%
% See also
%   CONV_SUB_2D
function [x_psi,meta_psi]=apply_band_pass_filters_at_fixed_scale(x,filters,j,options)
    % Options
    if(nargin<3)
        options = struct;
    end
    
    white_list = {'x_resolution','psi_mask','oversampling','type','padding'};
    check_options_white_list(options, white_list);
    options = fill_struct(options, 'x_resolution', 0);
    options = fill_struct(options, 'oversampling', 1);
    options = fill_struct(options, 'psi_mask', ...
        ones(1,numel(filters.psi.filter)));
    options = fill_struct(options, 'padding', 'symm');
    
    oversampling = options.oversampling;
    
    bdry = options.padding;
    switch lower(bdry)
        case {'symm','per'}
            center_sig = false;
        case 'zero'
            center_sig = true;
    end
    
    % Padding and Fourier transform
    sz_paded = filters.meta.size_filter / 2^options.x_resolution;
    xf = fft2(pad_signal(x, sz_paded, bdry, center_sig));

    % Band-pass filtering, downsampling and unpadding
    x_psi=cell(1,numel(find(psi_mask)));
    meta_psi = struct();
    
    filters_j=find_filters(filters,j); % we need a function that takes only filters at scale j
    
    for p = filters_j
        ds = max(floor(j)- options.x_resolution - oversampling, 0);
        x_psi{p} = conv_sub_2d(xf, filters.psi.filter{p}, ds);
        x_psi{p} = unpad_signal(x_psi{p}, ds*[1 1], size(x), center_sig);
        meta_psi.j(1,p) = j;
        meta_psi.theta(1,p) = filters.psi.meta.theta(p);
        meta_psi.resolution(1,p) = options.x_resolution+ds;
    end
    
end