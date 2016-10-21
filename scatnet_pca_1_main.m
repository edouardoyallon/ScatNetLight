%% TEMPORARY MAIN FOR PCA type 1

fprintf('loading options...\n');

load_path_software
option=struct;
option.Exp=struct;
option.Exp.Type='cifar10_PCA';
option.Exp.n_batches=1;
option.Exp.max_J=3;
option.Exp.log_features=false;
option.Exp.patch_size=[8 4];
option.General.path2database='./cifar-10-batches-mat';
option.General.path2outputs='./Output/';

size_signal = 32;

scat_opt.M = 2;

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

%% wavelet filters and input data
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
   x_train=x_train(:,:,:,1:100); 
   x_test=x_test(:,:,:,1:100); 
end

%% learning PCA filters
fprintf ('\nLEARNING -------------------------------------------\n\n')
fprintf ('size of experiment: train = %s, test = %s\n\n', num2str(size(x_train)), num2str(size(x_test)))

PCA_filters=cell(1,max_J);
PCA_evals=cell(1,max_J);
mus = cell(1, max_J);
et = cell(1, max_J);
patch_size = option.Exp.patch_size;

tic
U_j = cell(1, max_J);

for j=1:max_J
    fprintf ('compute scale %d...\n', j)
    U_j{j} = compute_J_scale(x_train, filters, j);
    U_j_vect = tensor_2_vector_PCA(U_j{j}, patch_size);
    fprintf ('standardization at scale %d...\n', j)
    [U_j_vect, mus{j}, et{j}] = standardize_feature(U_j_vect);
    fprintf ('PCA at scale %d...\n\n', j)
    [sv, d, F] = svd(U_j_vect'*U_j_vect, 'econ');
    %[F,~, d] = pca(U_j_vect, 'Economy', true);
    clear U_j_vect
    PCA_filters{j} = F;% ./ repmat(sqrt(diag(d)'), size(F, 1), 1);
    PCA_evals{j} = diag (d);
end

%% computing testing and training data
option.Exp.PCA_eps_ratio=0.001;
eps_ratio = option.Exp.PCA_eps_ratio;

fprintf ('CLASSIFICATION -------------------------------------------\n\n')
fprintf('testing...\n');
S_test = scat_PCA1(x_test, filters, PCA_filters, PCA_evals, eps_ratio, max_J, mus, et, true, patch_size);
fprintf ('training... \n')
sz = size(S_test, 2);
loops = ceil(size(x_train, 4) / sz);
S_train=zeros(size(S_test,1),size(x_train,4));
idx=1;
for i = 1 : loops
    IDX=idx:min([idx+sz-1,size(x_train,4)]);
    U_j_batch = cell(1, max_J);
    for j = 1 : max_J
        U_j_batch{j}=U_j{j}(:,:,:,IDX);
    end

    S_train(:,IDX) = scat_PCA1(U_j_batch, filters, PCA_filters, PCA_evals, eps_ratio, max_J, mus, et, false, patch_size);
    idx=idx+sz;
end

%% log features

if option.Exp.log_features
    S_train=log(0.0001 + S_train);
    S_test=log(0.0001 + S_test);
end

%% standardization

fprintf('standardizing...')
[S_train, mu, D]=standardize_feature(S_train');
S_test=standardize_feature(S_test', mu, D);
S_train=S_train';
S_test=S_test';
timeScat=toc;
fprintf(['\nscattering processed in ' num2str(timeScat) 's\n']);
%% svm classification

fprintf('classifying...\n')

option.Classification.C=10;
option.Classification.SIGMA_v=1;

dimension_reduction_and_SVM_PCA

save('PCA_filters', 'PCA_filters') 
save('PCA_evals', 'PCA_evals') 
save('result', 'ans')
save('confmat','confusion_matrix')

%EOF
