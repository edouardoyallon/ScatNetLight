% OPTIMIZE_FILTER_PARS_2D
% Optimizes the slant for the 2D Morlet wavelet filter bank
%
% Usage:
%   [slant,lp_ratio] = OPTIMIZE_FILTER_PARS_2D(N,J,L,Q,xi)
%
% Inputs:
%   1.) N (numeric): The size of the filters is NxN.
%   2.) J (numeric): The maximum scale.
%   3.) L (numeric): The number of angles in [0,pi)
%   4.) Q (numeric): The number of wavelets per octave.
%   5.) xi (numeric): The central fequency of the mother wavelet.
%
% Outputs:
%   1.) slant (numeric): The slant value the minimizes the frame bound
%       ratio.
%   2.) lp_ratio (numeric): The frame bound ratio.

function [slant,lp_ratio] = optimize_filter_pars_2d(N,J,L,Q,xi)

[slant,lp_ratio] = fminbnd(@(zeta) LP(N,J,L,Q,xi,zeta),0.1,2);

end

%% Littlewood-Paley function

function ratio = LP(N,J,L,Q,xi,zeta)

% Base scattering settings
scat_opt.M = 1;
scat_opt.trans_oversamp = 1;
scat_opt.rot_oversamp = Inf;
scat_opt.type = 't';

% Construct filters
[~,filters] = create_scattering_operators_2(N,N,scat_opt.type, J, L, Q, ...
    scat_opt.trans_oversamp, xi, scat_opt.rot_oversamp, scat_opt.M, ...
    zeta);

% Littlewood Paley
lwp = littlewood_paley(filters{1}.translation);
lwp = fftshift(lwp);
x = 1:size(lwp,1);
y = 1:size(lwp,2);
offset = [length(x)/2+1,length(y)/2+1];
x = x-offset(1);
y = y-offset(2);
[X,Y] = meshgrid(x,y);
Z = sqrt(X.^2 + Y.^2);
ind0 = Z <= length(x)/4;
ind = false(length(x),length(y));
ind(ind0) = true;
ratio = min(max(lwp(ind))/min(lwp(ind)),1e10);

end