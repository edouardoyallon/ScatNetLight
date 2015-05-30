function [Wop,filters]=create_scattering_operators(N,M,type,J)
% N: width of the image
% M: height of the image
% type: t/tr/tr_nonsepa
% J(optional)
%
% N,M can be some array if the used images are tensor(such as RGB images)


if(nargin<4)
J=5;
end



scat_opt.M=2;


% First layer
filt_opt.layer{1}.translation.J=J;
filt_opt.layer{1}.translation.L=8;
scat_opt.layer{1}.translation.oversampling=0;
filt_opt.layer{1}.translation.n_wavelet_per_octave=1;

% Second layer
% Translation
filt_opt.layer{2}.translation.J=J;
filt_opt.layer{2}.translation.L=8;
scat_opt.layer{2}.translation.oversampling=0;
scat_opt.layer{2}.translation.type=type;%define translation, rototranslation...


% - Rotation
filt_opt.layer{2}.rotation.J=2;
filt_opt.layer{2}.rotation.boundary = 'per'; % Periodic convolution, no symmetry used on the signal
filt_opt.layer{2}.rotation.filter_format = 'fourier_multires'; % Multiresolution fourier - simply means filter can be used at any sizes
filt_opt.layer{2}.rotation.P = 0; % A weird behavior of wavelet_1d add wlts if this it not set up
scat_opt.layer{2}.rotation.oversampling=0;
scat_opt.layer{2}.rotation.output_averaging=0;%if yes, output the averaging along angles in the S



% Third layer(copy of the previous one)
filt_opt.layer{3}=filt_opt.layer{2};
scat_opt.layer{3}=scat_opt.layer{2};


[Wop,filters]=wavelet_factory_2d([N,M],filt_opt,scat_opt);

end
