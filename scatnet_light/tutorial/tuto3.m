% How to understand filters?

% Fix a size of the image
N=64%256;
M=64%256;

% Fix now the parameters
Jspace=3 % scale in space
L=8 % number of angles
Jtheta=2 % scale in angle
filter_type_space='morlet'%available are haar/morlet/shannon
filter_type_angle='morlet_1d'%available are morlet/meyer

% Number of layers
scat_opt.M=2;
% First layer
filt_opt.layer{1}.translation.J=Jspace;
filt_opt.layer{1}.translation.L=2*L;
filt_opt.layer{1}.translation.slant_psi=2/3;
scat_opt.layer{1}.translation.oversampling=0;
filt_opt.layer{1}.translation.n_wavelet_per_octave=2;
filt_opt.layer{1}.translation.filter_type=filter_type_space;
% Second layer
% - Translation
filt_opt.layer{2}.translation.J=Jspace;
filt_opt.layer{2}.translation.L=L;
filt_opt.layer{2}.translation.filter_type=filter_type_space;
scat_opt.layer{2}.translation.oversampling=0;
scat_opt.layer{2}.translation.type='tr';
% - Rotation
filt_opt.layer{2}.rotation.J=Jtheta;
filt_opt.layer{2}.rotation.filter_type=filter_type_angle;
filt_opt.layer{2}.rotation.boundary = 'per'; % Periodic convolution, no symmetry used on the signal
filt_opt.layer{2}.rotation.filter_format = 'fourier_multires'; % Multiresolution fourier - simply means filter can be used at any sizes
filt_opt.layer{2}.rotation.P = 0; % A weird behavior of wavelet_1d add wlts if this it not set up
scat_opt.layer{2}.rotation.oversampling=1;
scat_opt.layer{2}.rotation.output_averaging=0;%if 1, output the averaging along angles in the S
% Third layer(copy of the previous one)
filt_opt.layer{3}=filt_opt.layer{2};
scat_opt.layer{3}=scat_opt.layer{2};

% Wop is a cell within the operators for scattering computations are.
% Filters simply correspond to the weights of the filters used in this
% network.
[Wop,filters]=wavelet_factory_2d([N,M],filt_opt,scat_opt);
figure,
display_filter_bank_2d(filters{1}.translation);% show 2D space filters
figure,
plot(littlewood_paley(filters{3}.rotation));% little wood paley 1D
figure,
display_littlewood_paley_2d(filters{1}.translation)% little wood plaley 2D