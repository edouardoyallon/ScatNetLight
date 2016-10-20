%% TEMPORARY MAIN FOR PCA type 2

fprintf('loading options...\n');

load_path_software
option=struct;
option.Exp=struct;
option.Exp.Type='cifar10_PCA';
option.Exp.n_batches=1;
option.Exp.max_J=3;
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
   x_train=x_train(:,:,:,1:250); 
   x_test=x_test(:,:,:,1:250); 
end

fprintf ('\nLEARNING -------------------------------------------\n\n')
fprintf ('size of experiment: train = %s, test = %s\n\n', num2str(size(x_train)), num2str(size(x_test)))

PCA_filters=cell(1,max_J);
PCA_evals=cell(1,max_J);

tic
S_j = x_train;
s=cell(1,max_J);
mu=cell(1,max_J);
d=cell(1,max_J);
for j=1:max_J
    fprintf ('h filtering at scale %d...\n', j)
    S_j_tilde = S_j; %haar_lp(S_j, j>2);
    if j > 2
       S_j_tilde=S_j_tilde(1:2:end,1:2:end, :, :); 
    end
    fprintf ('compute scale %d...\n', j)
    U_j = compute_J_scale(x_train, filters, j);
    
    Z_j = cat(3, U_j, S_j_tilde);
    
    [Z_j_vect, sz]=tensor_2_vector_PCA(Z_j);
    clear U_j
    
    clear S_j_tilde
    fprintf ('standardization at scale %d...\n', j)
    
    [Z_j_vect,mu{j},s{j}]=standardize_feature(Z_j_vect);
    
    fprintf ('SVD at scale %d...\n\n', j)
    [~,d{j},F] = svd(Z_j_vect'*Z_j_vect);
    clear U_j_vect
    PCA_filters{j} = eye(size(F)); 
    PCA_evals{j}=diag(d{j});
    proj = Z_j_vect * PCA_filters{j};
       
    S_j=vector_2_tensor_PCA(proj, sz);
end

%%
option.Exp.PCA_eps_ratio=0;
eps_ratio = option.Exp.PCA_eps_ratio;


fprintf ('CLASSIFICATION -------------------------------------------\n\n')
fprintf('testing...\n');
%S_test = scat_PCA2(x_test, filters, PCA_filters, PCA_evals, eps_ratio, max_J, mu, s);
fprintf ('training... \n')
S_train=S_j;
S_test=S_train;

train_size=size(S_train);
S_train=reshape(S_train, [train_size(1)*train_size(2)*train_size(3), train_size(4)]);
test_size=size(S_test);
S_test=reshape(S_test, [test_size(1)*test_size(2)*test_size(3), test_size(4)]);


%%

% fprintf('standardizing...')
% [S_train, mu, D]=standardize_feature(S_train');
% S_test=standardize_feature(S_test', mu, D);
% S_train=S_train';
% S_test=S_test';
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
