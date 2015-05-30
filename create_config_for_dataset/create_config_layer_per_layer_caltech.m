function [Wop,Wop_color,filt_opt,filt_opt_color]=create_config_layer_per_layer_caltech(options)
size_signal=options.Layers.size;
J=options.Layers.J;
scat_opt.M=2;

options.Layers = fill_struct(options.Layers, 'Type_scattering', 'tr');



% First layer
filt_opt.layer{1}.translation.J=J;
filt_opt.layer{1}.translation.L=8;
scat_opt.layer{1}.translation.oversampling=0;
filt_opt.layer{1}.translation.n_wavelet_per_octave=2; %2 = top result

% Second layer
% Translation
filt_opt.layer{2}.translation.J=J;
filt_opt.layer{2}.translation.L=8;
scat_opt.layer{2}.translation.oversampling=0;
scat_opt.layer{2}.translation.type=options.Layers.Type_scattering;

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


[Wop,filter]=wavelet_factory_2d([size_signal,size_signal],filt_opt,scat_opt);

% The parameters of the color are different : color in images are in lower
% frequency, so there is no need to apply the scattering on the full
% resolution image
size_signal_color=options.Layers.size_color;
ratio=log(options.Layers.size/options.Layers.size_color)/log(2);

J=options.Layers.J-ratio;
scat_opt_color.M=2;

% First layer
filt_opt_color.layer{1}.translation.J=J;
filt_opt_color.layer{1}.translation.L=8;
scat_opt_color.layer{1}.translation.oversampling=0;
filt_opt_color.layer{1}.translation.n_wavelet_per_octave=2;

% Second layer
% Translation
filt_opt_color.layer{2}.translation.J=J;
filt_opt_color.layer{2}.translation.L=8;
scat_opt_color.layer{2}.translation.oversampling=0;
scat_opt_color.layer{2}.translation.type=options.Layers.Type_scattering;

% - Rotation
filt_opt_color.layer{2}.rotation.J=2;
filt_opt_color.layer{2}.rotation.boundary = 'per'; % Periodic convolution, no symmetry used on the signal
filt_opt_color.layer{2}.rotation.filter_format = 'fourier_multires'; % Multiresolution fourier - simply means filter can be used at any sizes
filt_opt_color.layer{2}.rotation.P = 0; % A weird behavior of wavelet_1d add wlts if this it not set up
scat_opt_color.layer{2}.rotation.oversampling=1;
scat_opt_color.layer{2}.rotation.output_averaging=0;


% Third layer(copy of the previous one)
filt_opt_color.layer{3}=filt_opt.layer{2};
scat_opt_color.layer{3}=scat_opt.layer{2};


[Wop_color,filter_color]=wavelet_factory_2d([size_signal_color,size_signal_color],filt_opt_color,scat_opt_color);
end
