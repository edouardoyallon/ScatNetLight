% SCAT_3D_TUTORIALS
% 3D scattering tutorials
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

%% Tutorial #1: 
% Create scattering operator in same way as 2D software

% === Settings ===

% Size of signal
size_in = [32,32,32];

% --- Global scattering options ---
scat_opt.M = 1;
scat_opt.type = 't';

% --- First layer options ---

% Filters
filt_opt.layer{1}.translation.filter_type = 'morlet';
filt_opt.layer{1}.translation.J = 4;
filt_opt.layer{1}.translation.n_wavelet_per_octave = 1;
filt_opt.layer{1}.translation.base_mesh = 'oct';
filt_opt.layer{1}.translation.n_subdivision_sphere = 3;
filt_opt.layer{1}.translation.antipodal = false;
filt_opt.layer{1}.translation.sigma_phi = 0.8;
filt_opt.layer{1}.translation.sigma_psi = 0.8;
filt_opt.layer{1}.translation.xi_psi = 3*pi/4;
filt_opt.layer{1}.translation.slant_psi = 2/3;

% Scattering
scat_opt.layer{1}.translation.oversampling = 0;
scat_opt.layer{1}.translation.boundary = 'zero';

% --- Second layer options ---
filt_opt.layer{2} = filt_opt.layer{1};
scat_opt.layer{2} = scat_opt.layer{1};

% === Create wavelet operator and filters ===

[Wop, filters] = wavelet_factory_3d(size_in, filt_opt, scat_opt); 

% === Apply scattering transform to 3D signal ===

x = randn(size_in);
[S,U] = scat(x,Wop);

%% Tutorial #2:
% Create filters then wavelet operator separately. When doing parallel
% 3D scattering computations, it is significantly more memory efficient to
% only pass the filters to the workers, and to create the wavelet operator
% within each worker.
%
% Additionally, this method assumes and forces that the filters be the same
% at each scattering layer, unlike Tutorial #1.

% === Filters ===

% Size of signal
size_in = [32,32,32];

% Filter options
filt_opt.translation.filter_type = 'morlet';
filt_opt.translation.J = 4;
filt_opt.translation.n_wavelet_per_octave = 1;
filt_opt.translation.base_mesh = 'oct';
filt_opt.translation.n_subdivision_sphere = 3;
filt_opt.translation.antipodal = false;
filt_opt.translation.sigma_phi = 0.8;
filt_opt.translation.sigma_psi = 0.8;
filt_opt.translation.xi_psi = 3*pi/4;
filt_opt.translation.slant_psi = 2/3;

% Create filters
filters = filters_factory_3d([32 32 32], filt_opt);

% === Wavelet operator ===

% Scattering options
scat_opt.M = 1;
scat_opt.type = 't';
scat_opt.translation.oversampling = 0;
scat_opt.translation.boundary = 'zero';

% Create wavelet operators
[Wop, scat_opt] = wavelet_operator_3d(filters, scat_opt);
 
% === Apply scattering transform to 3D signal ===

x = randn(size_in);
[S,U] = scat(x,Wop);