%%
size_signal=32;
%%
J=5
filt_opt = default_filter_options('image', size_signal)
scat_opt.M=2;
% First layer
filt_opt.layer{1}.translation.J=J;
filt_opt.layer{1}.translation.L=8;
scat_opt.layer{1}.translation.oversampling=0;
filt_opt.layer{1}.translation.n_wavelet_per_octave=2;

% Second layer
% Translation
filt_opt.layer{2}.translation.J=J;
filt_opt.layer{2}.translation.L=8;
scat_opt.layer{2}.translation.oversampling=0;
scat_opt.layer{2}.translation.type='t';

% - Rotation
filt_opt.layer{2}.rotation.J=2;
filt_opt.layer{2}.rotation.boundary = 'per'; % Periodic convolution, no symmetry used on the signal
filt_opt.layer{2}.rotation.filter_format = 'fourier_multires'; % Multiresolution fourier - simply means filter can be used at any sizes
filt_opt.layer{2}.rotation.P = 0; % A weird behavior of wavelet_1d add wlts if this it not set up
scat_opt.layer{2}.rotation.oversampling=1;
scat_opt.layer{2}.rotation.output_averaging=0;

% Third layer(copy of the previous one)
filt_opt.layer{3}=filt_opt.layer{2};
scat_opt.layer{3}=scat_opt.layer{2};


%%
%[Wop,filters]=wavelet_factory_2d([size_signal,size_signal],filt_opt,scat_opt);

x=rand(32,32);
%filters=filters{1}.translation;
%%
S=scat_PCA(x,filters,{rand(64,32)},2)