%% TEMPORARY MAIN FOR PCA type 1

fprintf('loading options...\n');

load_path_software
option=struct;
option.Exp=struct;
option.Exp.Type='cifar10_PCA';
option.Exp.n_batches=1;
option.Exp.max_J=3;
option.Exp.log_features=true;
option.Exp.patch_size=[1 1];
option.Exp.PCA_eps_ratio=0;
option.Exp.random_rotations=0;
option.Exp.batch_size = 1000;
option.General.path2database='./cifar-10-batches-mat';
option.General.path2outputs='./Output/';
option.Classification.C=10;
option.Classification.SIGMA_v=1;

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

% Create the config specific to the dataset 
[class,getImage,score_function,split_function,Wop,Wop_color,ds,filt_opt_color]=recover_dataset(option);

x_train=getImage('train');
x_test=getImage('test');

% traning set!
x_train = single(rgb2yuv(x_train));
x_test = single(rgb2yuv(x_test));

max_J=option.Exp.max_J;
eps_ratio = option.Exp.PCA_eps_ratio;
batch_size = option.Exp.batch_size;

if debug_set
   x_train=x_train(:,:,:,1:500); 
   x_test=x_test(:,:,:,1:500); 
end


orig_train_size = size(x_train);

x_train = addRandomRotations(x_train, option.Exp.random_rotations, 'bilinear');


%% learning PCA filters
fprintf ('\nLEARNING -------------------------------------------\n\n')
fprintf ('size of experiment: train = %s, test = %s\n\n', num2str(orig_train_size), num2str(size(x_test)))
fprintf ('max J = %d, PCA epsilon = %g, C = %g, sigma = %g\n', max_J, eps_ratio, option.Classification.C, option.Classification.SIGMA_v);
fprintf ('patch size = %s, random rotations = %d\n\n', num2str(option.Exp.patch_size), option.Exp.random_rotations);

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
    %[U_j_vect, mus{j}, et{j}] = standardize_feature(U_j_vect');
    U_j_vect = bsxfun (@minus, U_j_vect, mean (U_j_vect, 2));
    fprintf ('PCA at scale %d...\n\n', j)
    [sv, d, F] = svd(U_j_vect'*U_j_vect, 'econ');
    %[F,~, d] = pca(U_j_vect, 'Economy', true);
    clear U_j_vect
    PCA_filters{j} = F; % ./ repmat(sqrt(diag(d)'), size(F, 1), 1);
    PCA_evals{j} = diag (d);
end

%% computing testing and training data

fprintf ('CLASSIFICATION -------------------------------------------\n\n')
fprintf('testing...\n');
S_test = scat_PCA1(x_test, filters, PCA_filters, PCA_evals, eps_ratio, max_J, mus, et, true, patch_size);

fprintf ('training... \n')
% remove data augmentation
x_train=x_train(:,:,:,1:orig_train_size(4));
for j = 1 : max_J
    U_j{j}=U_j{j}(:,:,:,1:orig_train_size(4));
end

loops = ceil(size(x_train, 4) / batch_size);
S_train=zeros(size(S_test,1),size(x_train,4));

idx=1;
for i = 1 : loops
    IDX=idx:min([idx+batch_size-1,size(x_train,4)]);
    U_j_batch = cell(1, max_J);
    for j = 1 : max_J
        U_j_batch{j}=U_j{j}(:,:,:,IDX);
    end

    S_train(:,IDX) = scat_PCA1(U_j_batch, filters, PCA_filters, PCA_evals, eps_ratio, max_J, mus, et, false, patch_size);
    idx=idx+batch_size;
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

dimension_reduction_and_SVM_PCA

save('PCA_filters', 'PCA_filters') 
save('PCA_evals', 'PCA_evals') 
save('result', 'ans')
save('confmat','confusion_matrix')

%EOF
