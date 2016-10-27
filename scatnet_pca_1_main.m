%% Main file for Scat-PCA type 1

fprintf ('[Scat-PCA type 1]\n\n');
fprintf('loading options...\n');

load_path_software
size_signal = 32;
debug_set = 1;

% experiment and classification parameters
option = struct;
option.Exp = struct;
option.Exp.Type = 'cifar10_PCA';
option.Exp.n_batches = 1;
option.Exp.max_J = 3;
option.Exp.log_features = false;
option.Exp.patch_size = [1 1];
option.Exp.PCA_eps_ratio = 0.001;
option.Exp.random_rotations = 0;
option.Exp.batch_size = 100;
option.Exp.second_only = false;
option.General.path2database = './cifar-10-batches-mat';
option.General.path2outputs = './Output/';
option.Classification.C = 10;
option.Classification.SIGMA_v = 1;

scat_opt.M = 2;

% first layer
filt_opt.layer{1}.translation.J = option.Exp.max_J;
filt_opt.layer{1}.translation.L = 8;
scat_opt.layer{1}.translation.oversampling = 0;
filt_opt.layer{1}.translation.n_wavelet_per_octave = 1;

% second layer - translation
filt_opt.layer{2}.translation.J = option.Exp.max_J;
filt_opt.layer{2}.translation.L = 8;
scat_opt.layer{2}.translation.oversampling = 0;
scat_opt.layer{2}.translation.type = 't';

% third layer(copy of the previous one)
filt_opt.layer{3} = filt_opt.layer{2};
scat_opt.layer{3} = scat_opt.layer{2};

%% wavelet filters and input data
[~, filters] = wavelet_factory_2d([size_signal, size_signal], filt_opt, scat_opt);

filters = filters{1}.translation; 

% create the config specific to the dataset 
[class, getImage, score_function, split_function, Wop, Wop_color, ds, filt_opt_color] = ...
    recover_dataset(option);

x_train = getImage('train');
x_test  = getImage('test');

% traning set!
x_train = single(rgb2yuv(x_train));
x_test = single(rgb2yuv(x_test));

% local copies
max_J = option.Exp.max_J;
second_only = option.Exp.second_only;
if second_only
    min_J = 2;
else
    min_J = 1;
end

eps_ratio = option.Exp.PCA_eps_ratio;
batch_size = option.Exp.batch_size;
patch_size = option.Exp.patch_size;

% cut data for debuggingz
if debug_set
   x_train = x_train(:, :, :, 1:500); 
   x_test  = x_test (:, :, :, 1:500); 
end

% store original size before data augmentation
orig_train_size = size(x_train);

fprintf ('\n--- LEARNING ---\n\n')
fprintf ('size of experiment:\n\ttrain = %s\n\ttest  = %s\n\n', ... 
    num2str(orig_train_size), num2str(size(x_test)))
fprintf ('max J = %d, PCA epsilon = %g, C = %g, sigma = %g\n', ...
    max_J, eps_ratio, option.Classification.C, option.Classification.SIGMA_v);
fprintf ('patch size = %s, random rotations = %d\n\n', num2str(option.Exp.patch_size), ...
    option.Exp.random_rotations);

% data augmentation
if option.Exp.random_rotations
    fprintf ('data augmentation...\n\n')
    x_train = addAugmentedImages(x_train, option.Exp.random_rotations, 'bilinear');
end

%% learning PCA filters


PCA_filters = cell(1, max_J);
PCA_evals = cell(1, max_J);
U_j = cell(1, max_J);

tic
for j = min_J:max_J
    loops = ceil(size(x_train, 4) / batch_size);
    
    idx = 1;
    ex = 0;
    ex2 = 0;    
    for r = 1 : loops
        fprintf('computing scale %d, learning batch %d/%d...\n', j, r, loops)
        IDX = idx:min ([idx + batch_size - 1, size(x_train, 4)]);
        U_j = compute_J_scale(x_train(:, :, :, IDX), filters, ...
            j, second_only);
        z = tensor_2_vector_PCA(U_j, patch_size);
        clear U_j;
        ex = ex + mean(z, 1); 
        ex2 = ex2 + z'*z / batch_size;
        idx = idx + batch_size;
    end

    ex = ex / (loops);
    ex2 = ex2 / (loops);
    Xcov = ex2 - ex' * ex;
    
    fprintf ('computing PCA at scale %d (%d x %d)...\n\n', j, size(Xcov, 1), ...
        size(Xcov, 2));
    [sv, d, F] = svd(Xcov, 'econ');
    clear U_j_vect
    PCA_filters{j} = F;
    PCA_evals{j} = diag (d);
end

%% computing testing and training data

fprintf ('--- CLASSIFICATION ---\n\n')

idx = 1;
loops = ceil(size(x_test, 4) / batch_size);

fprintf ('guide samples...\n') %to infer proper size
guide = scat_PCA1(x_test(:, :, :, 1:2), filters, PCA_filters, ...
        PCA_evals, eps_ratio, max_J, patch_size, second_only);
    
S_test = zeros(size(guide, 1), size(x_test, 4));
fprintf ('\n');
for r = 1 : loops
    fprintf('test batch %d/%d...\n', r, loops)
    IDX = idx:min([idx + batch_size - 1, size(x_test, 4)]);
    S_test(:, IDX) = scat_PCA1(x_test(:, :, :, IDX), filters, PCA_filters, ...
        PCA_evals, eps_ratio, max_J, patch_size, second_only);
    idx = idx + batch_size;
end

% remove data augmentation
if option.Exp.random_rotations
    x_train = x_train(:, :, :, 1:orig_train_size(4));
end

loops = ceil(size(x_train, 4) / batch_size);
S_train=zeros(size(S_test, 1), size(x_train, 4));
fprintf ('\n');
idx = 1;
for i = 1 : loops
    IDX = idx:min([idx + batch_size - 1, size(x_train, 4)]);
    fprintf('train batch %d/%d...\n', i, loops)
    S_train(:, IDX) = scat_PCA1(x_train(:, :, :, IDX), filters, PCA_filters, PCA_evals, ... 
        eps_ratio, max_J, patch_size, second_only);
    idx = idx + batch_size;
end

timeScat = toc;

fprintf(['\nscattering processed in ' num2str(timeScat) 's\n\n']);


%% log features

if option.Exp.log_features
    S_train = log(0.0001 + S_train);
    S_test = log(0.0001 + S_test);
end

%% standardization

fprintf('standardizing...\n')
[S_train, mu, D] = standardize_feature(S_train');
S_test = standardize_feature(S_test', mu, D);
S_train = S_train';
S_test = S_test';


%% svm classification

fprintf('classifying...\n')

dimension_reduction_and_SVM_PCA

save('PCA_filters', 'PCA_filters') 
save('PCA_evals', 'PCA_evals') 
save('result', 'score')
save('confmat','confusion_matrix')

%EOF
