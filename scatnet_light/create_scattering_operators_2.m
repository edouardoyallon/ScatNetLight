function [Wop,filters]=create_scattering_operators_2(N,M,type,J,L,Q,t_os,xi_psi,r_os,num_layers,slant,bdry)
% N: width of the image
% M: height of the image
% type: t/tr/tr_nonsepa
% J: Number of scales
% L: Number of angles
% Q: Number of wavelets per octave
% t_os: Oversample translation by 2^trans_oversamp
% xi_psi: Center frequency for translation wavelets
% r_os: Rotation oversampling
% num_layers: Number of scattering layers (<= 2)
% slant: Eccintricity of ellipse
% bdry: Type of boundary conditions ('symm', 'per', 'zero')
%
% N,M can be some array if the used images are tensor(such as RGB images)

% Optional inputs
if length(Q) == 1
    Q = [Q,Q];
end
if nargin < 10
    scat_opt.M=2;
else
    scat_opt.M = num_layers;
end
if nargin < 11
    slant = 4/L;
end
if nargin < 12
    bdry = 'zero';
end

% First layer (translation)
filt_opt.layer{1}.translation.J = J;
filt_opt.layer{1}.translation.L = L;
filt_opt.layer{1}.translation.n_wavelet_per_octave = Q(1);
filt_opt.layer{1}.translation.xi_psi = xi_psi;
filt_opt.layer{1}.translation.slant_psi = slant;
scat_opt.layer{1}.translation.oversampling = t_os;
scat_opt.layer{1}.translation.padding = bdry;

% Second layer

% - Translation
filt_opt.layer{2}.translation.J = J;
filt_opt.layer{2}.translation.L = L;
filt_opt.layer{2}.translation.n_wavelet_per_octave = Q(2);
filt_opt.layer{2}.translation.xi_psi = xi_psi;
filt_opt.layer{2}.translation.slant_psi = slant;
scat_opt.layer{2}.translation.oversampling = t_os;
scat_opt.layer{2}.translation.padding = bdry;
scat_opt.layer{2}.translation.type = type; % define translation, rototranslation...

% - Rotation
filt_opt.layer{2}.rotation.J=floor(log2(L));
filt_opt.layer{2}.rotation.boundary = 'per'; % Periodic convolution, no symmetry used on the signal
filt_opt.layer{2}.rotation.filter_format = 'fourier_multires'; % Multiresolution fourier - simply means filter can be used at any sizes
filt_opt.layer{2}.rotation.P = 0; % A weird behavior of wavelet_1d add wlts if this it not set up
scat_opt.layer{2}.rotation.oversampling=r_os;
scat_opt.layer{2}.rotation.output_averaging=0; % if yes, output the averaging along angles in the S

% Third layer(copy of the previous one)
filt_opt.layer{3}=filt_opt.layer{2};
scat_opt.layer{3}=scat_opt.layer{2};

[Wop,filters]=wavelet_factory_2d([N,M],filt_opt,scat_opt);

end