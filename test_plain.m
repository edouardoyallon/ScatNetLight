%% TEMPORARY MAIN FOR PCA type 1

fprintf('loading options...\n');

load_path_software
option=struct;
option.Exp=struct;
option.Exp.Type='cifar10_PCA';
option.Exp.n_batches=1;
option.Exp.max_J=3;
option.Exp.log_features=false;
option.General.path2database='./cifar-10-batches-mat';
option.General.path2outputs='./Output/';

size_signal=32;

scat_opt.M=2;

debug_set = 1;

% First layer
filt_opt.layer{1}.translation.J=option.Exp.max_J;
filt_opt.layer{1}.translation.L=8;
scat_opt.layer{1}.translation.oversampling=0;
filt_opt.layer{1}.translation.n_wavelet_per_octave=1;

% Second layer
% Translation
filt_opt.layer{2}.translation.J=option.Exp.max_J;
filt_opt.layer{2}.translation.L=8;
scat_opt.layer{2}.translation.oversampling=0;
scat_opt.layer{2}.translation.type='t';

% Third layer(copy of the previous one)
filt_opt.layer{3}=filt_opt.layer{2};
scat_opt.layer{3}=scat_opt.layer{2};

%%
[~,filters]=wavelet_factory_2d([size_signal,size_signal],filt_opt,scat_opt);

%x=rand(32,32);
filters=filters{1}.translation; 

% Create the config specific to the dataset023
[class,getImage,score_function,split_function,Wop,Wop_color,ds,filt_opt_color]=recover_dataset(option);

x_train=getImage('train');
x_test=getImage('test');

% traning set!
x_train = single(rgb2yuv(x_train));
x_test = single(rgb2yuv(x_test));

max_J=option.Exp.max_J;


if debug_set
   x_train=x_train(:,:,:,1:30); 
   x_test=x_test(:,:,:,1:30); 
end

tic
S_train = scat(x_train, Wop);
S_test = scat(x_test, Wop);

S_train = scat_to_tensor(S_train);
sz = size(S_train);
S_train=reshape(S_train, [sz(1) * sz(2), sz(3)]);

S_test = scat_to_tensor(S_test);
sz = size(S_test);
S_test=reshape(S_test, [sz(1) * sz(2), sz(3)]);

%%

fprintf('standardizing...')
[S_train, mu, D]=standardize_feature(S_train');
S_test=standardize_feature(S_test', mu, D);
S_train=S_train';
S_test=S_test';
timeScat=toc;
fprintf(['\nscattering processed in ' num2str(timeScat) 's\n']);
%%
fprintf('classifying...\n')

option.Classification.C=10;
option.Classification.SIGMA_v=1;

dimension_reduction_and_SVM_PCA

save('PCA_filters', 'PCA_filters') 
save('PCA_evals', 'PCA_evals') 
save('result', 'ans')
save('confmat','confusion_matrix')

%EOF
