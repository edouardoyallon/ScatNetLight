% SCAT_1D_TUTORIALS
% 1D scattering tutorials
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: mhirn@msu.edu

%% Tutorial #1

% === Filters ===

% Length of the signal
N = 2^7;

% Filter options
filt_opt.filter_type = 'morlet';
filt_opt.translation.J = log2(N);
filt_opt.n_wavelet_per_octave = 2;
filt_opt.xi_psi = 3*pi/4;
filt_opt.sigma_phi = 0.34; % 0.30 (Q=1); 0.34 (Q=2); 
filt_opt.sigma_psi = 0.8;

% Create filters
filters = filters_factory_1d(N, filt_opt);

% === Wavelet operator and scattering options ===

% Scattering options
scat_opt.M = 2;
scat_opt.oversampling = 1;
scat_opt.boundary = 'zero';
scat_opt.compute_low_pass = true;

% Create wavelet operators
[Wop, scat_opt] = wavelet_operator_1d(filters, scat_opt);