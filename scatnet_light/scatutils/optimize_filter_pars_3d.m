% OPTIMIZE_FILTER_PARS_3D
% Optimizes the slant for the 3D Morlet wavelet filter bank
%
% Usage:
%   [slant,lp_ratio] = OPTIMIZE_FILTER_PARS_3D(N,J,n_sub_sphere,Q,xi)
%
% Inputs:
%   1.) N (numeric): The size of the filters is NxNxN.
%   2.) J (numeric): The maximum scale.
%   3.) base_mesh (string): The base mesh for the sampling of the sphere.
%   4.) n_sub_sphere (numeric): The number of subdivisions of the sphere.
%   5.) Q (numeric): The number of wavelets per octave.
%   6.) xi (numeric): The central fequency of the mother wavelet is
%       (0,0,xi).
%
% Outputs:
%   1.) slant (numeric): The slant value the minimizes the frame bound
%       ratio.
%   2.) lp_ratio (numeric): The frame bound ratio.
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

function [slant,lp_ratio] = optimize_filter_pars_3d(N,J,base_mesh,n_sub_sphere,Q,xi)

[slant,lp_ratio] = fminbnd(@(zeta) LP(N,J,base_mesh,n_sub_sphere,Q,xi,zeta),0.1,4);

end

%% Littlewood-Paley function

function ratio = LP(N,J,base_mesh,n_sub_sphere,Q,xi,zeta)

% Filter options
filt_opt.translation.filter_type = 'morlet';
filt_opt.translation.J = J;
filt_opt.translation.n_wavelet_per_octave = Q;
filt_opt.translation.base_mesh = base_mesh;
filt_opt.translation.n_subdivision_sphere = n_sub_sphere;
filt_opt.translation.antipodal = true;
filt_opt.translation.sigma_phi = 0.8;
filt_opt.translation.sigma_psi = 0.8;
filt_opt.translation.xi_psi = xi;
filt_opt.translation.slant_psi = zeta;

% Create filter bank
filters = filters_factory_3d([N N N], filt_opt);

% Littlewood Paley
lwp = littlewood_paley(filters.translation);
lwp = fftshift(lwp);
x = 1:size(lwp,1);
y = 1:size(lwp,2);
z = 1:size(lwp,3);
offset = [length(x)/2+1,length(y)/2+1,length(z)/2+1];
x = x-offset(1);
y = y-offset(2);
z = z-offset(3);
[X,Y,Z] = meshgrid(x,y,z);
R = sqrt(X.^2 + Y.^2 + Z.^2);
ind0 = R <= length(x)/4;
ind = false(length(x),length(y),length(z));
ind(ind0) = true;
ratio = min(max(lwp(ind))/min(lwp(ind)),1e10);

end