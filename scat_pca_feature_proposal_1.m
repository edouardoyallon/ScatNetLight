 % This is the main script to compute a scattering representation, given
% options.
option=struct;
option.Exp=struct;
option.Exp.Type='cifar10_PCA';
option.Exp.n_batches=1;
option.Exp.max_J=2;
   option.General.path2database='./cifar-10-batches-mat';
    option.General.path2outputs='./Output/';
option.Classification.C=1;
option.Classification.SIGMA_v=1;
%%
size_signal=32;
%%
J=5

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
[Wop,filters]=wavelet_factory_2d([size_signal,size_signal],filt_opt,scat_opt);

%x=rand(32,32);
filters=filters{1}.translation;

% Clear every previous batch of the works
fprintf('Load options...\n');

% Create the config specific to the dataset023
[class,getImage,score_function,split_function,Wop,Wop_color,ds,filt_opt_color]=recover_dataset(option);

x_train=getImage('train');
x_test=getImage('test');



% traning set!
x_train = single(rgb2yuv(x_train));
x_test = single(rgb2yuv(x_test));


max_J=option.Exp.max_J;

x_train=x_train(:,:,:,1:30);
%x_test=x_test(:,:,:,1:30);

PCA_filters=cell(1,max_J);
tic
%%%% sep
% Train procude on the training set
for j=1:max_J
    j
    U_j = compute_j_scale(x_train, filters, j);
    j
    U_j_vect=tensor_2_vector_PCA(U_j);
    j
    [Fp,~,F] = svd(U_j_vect'*U_j_vect);
    j
    PCA_filters{j} = F;
    j
end

S_train = scat_PCA1(x_train,filters,PCA_filters,max_J);
fprintf('train done')
S_test = scat_PCA1(x_test,filters,PCA_filters,max_J);
fprintf('test done')
%%%% sep

[S_train,mu,D]=standardize_feature(S_train');
S_test=standardize_feature(S_test',mu,D);

S_train=S_train';
S_test=S_test';



timeScat=toc;
fprintf(['\nScat layer processed in ' num2str(timeScat) 's\n']);




% Reduce dimension + Classification framework
dimension_reduction_and_SVM_PCA