% SCAT_2D_TUTORIAL
% 2D scattering tutorials
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

%% Tutorial #1
% Create a scattering operator, apply it to a signal, and compute averages
% to get translation and rotation invariant features.
%
% This tutorial should be a good place to start for most problems.
% Initially, the only thing you will want to change is the variable
% SIZE_IN, which is the size of your signal, and
% FILT_OPT.LAYER{1}.TRANSLATION.J, which is the number of octaves/scales in
% the wavelet transform. A good general rule is, if SIZE_IN = [N,N], then
% FILT_OPT.LAYER{1}.TRANSLATION.J = log2(N).
%
% After that, you may want to increase the angular sampling by increasing
% FILT_OPT.LAYER{1}.TRANSLATION.L. A larger L means more angles are
% sampled in the wavelet transform. It is already set to 8 angles in [0,pi)
% though (so 16 angles over the circle), which is usually enough.
%
% Another option you can play with is
% FILT_OPT.LAYER{1}.TRANSLATION.N_WAVELET_PER_OCTAVE. The default is 1,
% which means there is one wavelet covering each frequency band. A value of
% 2 means two wavelets per frequency band, etc. Sometimes setting it to 2
% can give better performance; beyond 2 there are diminishing returns.
%
% Finally, you can adjust the type of wavelet transform in the 2nd layer.
% This is done through SCAT_OPT.LAYER{2}.TYPE. See below for details.

% === Settings ===

% --- Size of signal ---
size_in = [32,32];      % Size of the signal [does not have to be square]

% --- Global scattering options ---
scat_opt.M = 2;         % Number of scattering layers [M=1,2]

% --- First layer options ---

% - Translation - [first layer only has wavelet transform over translation group]

% Filters
filt_opt.layer{1}.translation.filter_type = 'morlet';       % Type of wavelet [must be 'morlet']
filt_opt.layer{1}.translation.J = 5;                        % Number of octaves/scales [if signal is NxN, J<=log2(N)]
filt_opt.layer{1}.translation.n_wavelet_per_octave = 1;     % Number of wavelets per octave
filt_opt.layer{1}.translation.L = 8;                        % Number of angles in [0,pi) [symmetry of Morlet wavelet means only need to sample on half circle]
filt_opt.layer{1}.translation.sigma_phi = 0.8;              % Width of low pass filter isotropic Gaussian
filt_opt.layer{1}.translation.sigma_psi = 0.8;              % Width of high pass wavelet anisotropic Gaussian envelope
filt_opt.layer{1}.translation.xi_psi = 3*pi/4;              % Central frequency of mother wavelet
filt_opt.layer{1}.translation.slant_psi = 2/3;              % Eccentricity of the ellipsoidal Gaussian envelope of the Morlet wavelet

% Scattering
scat_opt.layer{1}.translation.oversampling = 1;             % Spatial oversampling by 2^x [x=0 is critical sampling rate, usually set x=1 to avoid aliasing]
scat_opt.layer{1}.translation.padding = 'zero';             % Boundary conditions [can be 'zero','per', or 'symm' for zero boundary, periodic boundary, or symmetric boundary] 

% --- Second layer options --- [need to set even if M=1]

% - Translation - 

% Filters 
%   [Generally want the same settings as the first layer, especially if 
%   M=1. However, you can change them as needed. For example, you may want 
%   2 wavelets per octave in the first layer, but only one wavelet per 
%   octave in the second layer.]
filt_opt.layer{2}.translation = filt_opt.layer{1}.translation;

% Scattering
%   [Like with the filters, generally want the same settings as the first
%   layer, but you must also set the type of wavelet transform in the
%   second layer.]
scat_opt.layer{2}.translation = scat_opt.layer{1}.translation;
scat_opt.layer{2}.translation.type = 't';
%   [Type of 2nd layer scattering transform. The options are 't', 'tr', and
%   'tr_nonsepa'. For a wavelet transform only over the translation group,
%   select 't'. For a wavelet transform over the translation group and
%   rotation group (direct product), select 'tr'. For a wavelet transform
%   over the group of rigid motions (translation and rotation semi-direct
%   product), select 'tr_nonsepa']

% - Rotation - 
%   [must be set if the wavelet transform type is 'tr' or 'tr_nonsepa'.
%   However, in general these should not be touched.]

% Filters
filt_opt.layer{2}.rotation.J = floor(log2(filt_opt.layer{2}.translation.L));
filt_opt.layer{2}.rotation.boundary = 'per';
filt_opt.layer{2}.rotation.filter_format = 'fourier_multires';
filt_opt.layer{2}.rotation.P = 0;

% Scattering
scat_opt.layer{2}.rotation.oversampling = Inf;
scat_opt.layer{2}.rotation.output_averaging = 0;

% --- Third layer options --- [only need to set if M=2; just copy layer 2]

filt_opt.layer{3} = filt_opt.layer{2};
scat_opt.layer{3} = scat_opt.layer{2};

% === Create wavelet operator and filters ===

[Wop,filters]=wavelet_factory_2d(size_in,filt_opt,scat_opt);

% === Apply scattering transform to a 2D signal ===

f = phantom(min(size_in));      % 2D signal [phantom must be square]
[S,U] = scat(f,Wop);            % Compute scattering of f

% Compute expected (or average) scattering coefficients, by taking the
% average of each function in U over translations and rotations. Thus no
% matter which type of scattering transform you use (t/tr/tr_nonsepa), the
% resulting coefficients EU are translation and rotation invariant.
EU = expected_scat_light_2d(U, scat_opt.layer{2}.translation.type, 1);








