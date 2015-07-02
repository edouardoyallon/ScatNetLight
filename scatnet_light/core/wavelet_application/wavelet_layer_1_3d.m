% WAVELET_LAYER_1_3D
% Compute the first layer wavelet tranform over the 3D translation group
%
% Usage:
%   [U_phi, U_psi] = WAVELET_LAYER_1_3D(U, filters, options)
%
% Input:
%   1.) U (struct): Previous scattering layer (zero layer)
%   2.) filters (struct): Filter bank for 1st layer
%   3.) options (struct): Options for the wavelet transform, as in
%       WAVELET_3D
%
% Output:
%   1.) U_phi (struct): Average (low pass) of wavelet coefficients
%   2.) U_psi (struct): Wavelet coefficients of next layer
%
% Description
%   This function has a pivotal role between WAVELET_3D (which computes a
%   single wavelet transform), and WAVELET_FACTORY_3D (which creates the
%   whole cascade). Given an input corresponding to the initial signal,
%   WAVELET_LAYER_1_3D computes the wavelet transform coefficients of the 
%   first layer using WAVELET_3D.
%
% See also
%   WAVELET_3D, WAVELET_FACTORY_3D
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr


function [U_phi, U_psi] = wavelet_layer_1_3d(U, filters, options)

% Fill in possibly missing fields of U
if ~isfield(U.meta,'axis')
    U.meta.axis = zeros(0,size(U.meta.j,2));
end

if ~isfield(U.meta, 'resolution'),
    U.meta.resolution = 0;
end

% Calculate band pass
calculate_psi = (nargout >= 2);

% Compute wavelet transform of signals in U
p2 = 1;
for p=1:numel(U.signal)
    
    % Get current signal and scale
    x = U.signal{p};
    if numel(U.meta.j) > 0
        j = U.meta.j(end,p);
    else
        j = -1e20;
    end
    
    % Get progressive paths
    options.psi_mask = calculate_psi & (filters.psi.meta.j >= j+1);
    
    % Set resolution of signal
    options.x_resolution = U.meta.resolution(p);
    
    % Compute wavelet transform
    [x_phi, x_psi, meta_phi, meta_psi] = wavelet_3d(x, filters, options);
    
    % Copy signal and meta for phi
    U_phi.signal{p} = x_phi;
    U_phi.meta.j(:,p) = filters.phi.meta.J;
    U_phi.meta.resolution(1,p) = meta_phi.resolution;
    
    % Copy signal and meta for psi
    for p_psi = find(options.psi_mask)
        U_psi.signal{p2} = x_psi{p_psi};
        U_psi.meta.j(1,p2) = filters.psi.meta.j(p_psi);
        U_psi.meta.axis(:,p2) = filters.psi.meta.axis(:,p_psi);
        U_psi.meta.resolution(1,p2) = meta_psi.resolution(p_psi);
        p2 = p2 + 1;
    end
    
end
U_phi.meta.axis = U.meta.axis;

% Organize orbits of band pass transforms
if calculate_psi
    scales_p = unique(filters.psi.meta.j);
    axis_p = unique(filters.psi.meta.axis','rows','stable');
    meta_axis = cell(1,length(scales_p));
    for s=1:length(scales_p)
        for l=1:length(axis_p)
            temp1 = find(U_psi.meta.j(1,:)==scales_p(s));
            temp2 = ismember(U_psi.meta.axis',filters.psi.meta.axis(:,l)','rows');
            temp2 = find(temp2 == true);
            meta_axis{s}(l) = intersect(temp1,temp2);
        end
        U_orb.meta.resolution(1,s) = meta_psi.resolution(meta_axis{s}(1));
        U_orb.meta.j(s) = scales_p(s);
    end
    U_orb.signal = format_orbit(U_psi.signal, meta_axis, 4);
    U_psi = U_orb;
    U_psi.meta.axis = axis_p';
    U_psi.meta.layer = 1;
end

end