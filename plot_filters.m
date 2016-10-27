load('PCA_filters')
load('PCA_evals')

size_signal = 32;
scat_opt.M = 2;

% first layer
filt_opt.layer{1}.translation.J = 3;
filt_opt.layer{1}.translation.L = 8;
scat_opt.layer{1}.translation.oversampling = 0;
filt_opt.layer{1}.translation.n_wavelet_per_octave = 1;

% second layer - translation
filt_opt.layer{2}.translation.J = 3;
filt_opt.layer{2}.translation.L = 8;
scat_opt.layer{2}.translation.oversampling = 0;
scat_opt.layer{2}.translation.type = 't';

% third layer(copy of the previous one)
filt_opt.layer{3} = filt_opt.layer{2};
scat_opt.layer{3} = scat_opt.layer{2};

[~, filters] = wavelet_factory_2d([size_signal, size_signal], filt_opt, scat_opt);

filters = filters{1}.translation; 

F = PCA_filters{3};

figure; imagesc (reshape (permute (reshape(abs (F(1:64, 1:64)), [8 8 8 8]), [1 3 2 4]), [64 64])); axis 'equal'

figure 
subplot(311)
F1col = reshape (permute (reshape(F(1:384, 4), [8 8 2 3]), [1 3 2 4]), [16 24]);
imagesc (real(F1col))
subplot(312)
F2col = reshape (permute (reshape(F(1:384, 5), [8 8 2 3]), [1 3 2 4]), [16 24]);
imagesc (real(F2col))
subplot(313)
F3col = reshape (permute (reshape(F(1:384, 6), [8 8 2 3]), [1 3 2 4]), [16 24]);
imagesc (real(F3col))


