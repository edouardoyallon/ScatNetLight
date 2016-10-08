
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
function [x_psi,meta_psi]=get_first_and_second_order_coefficients_at_fixed_resolution(x,filters,j,options)

calculate_psi = (nargout>=2); % do not compute any convolution
% with psi if the user does get U_psi

if ~isfield(U.meta,'theta')
    U.meta.theta = zeros(0,size(U.meta.j,2));
end

if ~isfield(U.meta, 'resolution'),
    U.meta.resolution = 0;
end

L=filters.meta.L;

filters_up_to_J = % we need to build a function that gets filters up to scale J


    
    if (numel(U.meta.j)>0)
        j = U.meta.j(end,p);
    else
        j = -1E20;
    end
    [x_phi, x_psi, meta_phi, meta_psi] = wavelet_2d(x, filters, options);

    % compute mask for progressive paths
    options.psi_mask = calculate_psi & ...
        (filters.psi.meta.j >= j+1);% + filters.meta.n_wavelet_per_octave);
    
    % set resolution of signal
    options.x_resolution = U.meta.resolution(p);
    
    % compute wavelet transform
    
    
    % copy signal and meta for phi
    U_phi.signal{p} = x_phi;
    U_phi.meta.j(:,p) = [U.meta.j(:,p); filters.phi.meta.J];
    U_phi.meta.theta(:,p) = U.meta.theta(:,p);
    U_phi.meta.resolution(1,p) = meta_phi.resolution;
    
    % copy signal and meta for psi
    for p_psi = find(options.psi_mask)
        U_psi.signal{p2} = x_psi{p_psi};
        U_psi.meta.j(:,p2) = [U.meta.j(:,p);...
            filters.psi.meta.j(p_psi)];
        U_psi.meta.theta(:,p2) = [U.meta.theta(:,p);...
            filters.psi.meta.theta(p_psi)];
        U_psi.meta.resolution(1,p2) = meta_psi.resolution(p_psi);
        p2 = p2 +1;
    end

    V_psi = modulus (U_psi);
    
    % Now we apply V_psi only to filters that have scalre less than j
    [x_psi,meta_psi]=apply_band_pass_filters_at_fixed_scale(x,filters,j,options)
    
       
    % copy signal and meta for phi
    U_phi.signal{p} = x_phi;
    U_phi.meta.j(:,p) = [U.meta.j(:,p); filters.phi.meta.J];
    U_phi.meta.theta(:,p) = U.meta.theta(:,p);
    U_phi.meta.resolution(1,p) = meta_phi.resolution;
    
    % copy signal and meta for psi
    for p_psi = find(options.psi_mask)
        U_psi.signal{p2} = x_psi{p_psi};
        U_psi.meta.j(:,p2) = [U.meta.j(:,p);...
            filters.psi.meta.j(p_psi)];
        U_psi.meta.theta(:,p2) = [U.meta.theta(:,p);...
            filters.psi.meta.theta(p_psi)];
        U_psi.meta.resolution(1,p2) = meta_psi.resolution(p_psi);
        p2 = p2 +1;
    end

    
end