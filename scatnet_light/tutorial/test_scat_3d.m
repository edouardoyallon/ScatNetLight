% TEST_SCAT_3D
% Tests the 3D scattering software
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

%% Settings

% --- Signal ---
N = [32,32,32];

% --- Global scattering
scat_opt.M = 1;
scat_opt.type = 't';

% --- First layer ---

% Filters
filt_opt.layer{1}.translation.J = 5;
filt_opt.layer{1}.translation.n_wavelet_per_octave = 1;
filt_opt.layer{1}.translation.base_mesh = 'oct';
filt_opt.layer{1}.translation.n_subdivision_sphere = 2;
filt_opt.layer{1}.translation.antipodal = false;
filt_opt.layer{1}.translation.sigma_phi = 0.8;
filt_opt.layer{1}.translation.sigma_psi = 0.8;
filt_opt.layer{1}.translation.xi_psi = 3*pi/4;
filt_opt.layer{1}.translation.slant_psi = 2/3;

% Scattering
scat_opt.layer{1}.translation.oversampling = 1;
scat_opt.layer{1}.translation.boundary = 'zero';

% --- Second layer ---
filt_opt.layer{2} = filt_opt.layer{1};
scat_opt.layer{2} = scat_opt.layer{1};

%% Create filterbank

[Wop, filters] = wavelet_factory_3d(N, filt_opt, scat_opt); 

%% Load 3D signal

x = randn(N);

%% Scattering

[S,U] = scat(x,Wop);