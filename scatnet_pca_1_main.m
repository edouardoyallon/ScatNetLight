%% TEMPORARY MAIN FOR PCA type 1
load_path_software
option=struct;
option.Exp=struct;
option.Exp.Type='cifar10_PCA';
option.Exp.n_batches=1;
option.Exp.max_J=3;
option.General.path2database='./cifar-10-batches-mat';
option.General.path2outputs='./Output/';
option.Classification.C=1;
option.Classification.SIGMA_v=1;

size_signal=32;

scat_opt.M=2;

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

%%
if 0
   x_train=x_train(:,:,:,1:30); 
   x_test=x_test(:,:,:,1:30); 
end

fprintf ('size of experiment: train = %s, test = %s\n\n', num2str(size(x_train)), num2str(size(x_test)))
PCA_filters=cell(1,max_J);
PCA_evals=cell(1,max_J);
fprintf('training...\n')
tic

for j=1:max_J
    fprintf ('compute scale %d...', j)
    tic;
    U_j = compute_J_scale(x_train, filters, j);
    compj=toc;
    fprintf ('%g s\n', num2str(compj))
    fprintf ('vector building at scale %d...', j)
    tic;
    U_j_vect=tensor_2_vector_PCA(U_j);
    size(U_j_vect)
    vecj=toc;
    fprintf ('%g s\n', num2str(vecj))
    fprintf ('SVD at scale %d...', j)
    tic;
    [U_j_vect, ~,D]=standardize_feature(U_j_vect');
    U_j_vect=U_j_vect';
    [~,d,F] = svd(U_j_vect'*U_j_vect);
    svdj=toc;
    fprintf ('%g s\n', num2str(svdj))
    PCA_filters{j} = F'; % * D;
    PCA_evals{j}=diag(d);
end

clear U_j
clear U_j_vect

tic
fprintf ('scat_pca...');
S_train = scat_PCA1(x_train,filters,PCA_filters,max_J);
traintime=toc;
fprintf('done in %g s\ntesting...', num2str(traintime))
tic
S_test = scat_PCA1(x_test,filters,PCA_filters,max_J);
testtime=toc;
fprintf('done in %g s\nstandardizing...', num2str(testtime))
[S_train,mu,D]=standardize_feature(S_train');
S_test=standardize_feature(S_test',mu,D);
S_train=S_train';
S_test=S_test';
timeScat=toc;
fprintf(['done\nscattering processed in ' num2str(timeScat) 's\n']);
%%
fprintf('classifying...\n')
dimension_reduction_and_SVM_PCA

save('PCA_filters', 'PCA_filters') 
save('PCA_evals', 'PCA_evals') 
save('result', 'ans')
save('confmat','confusion_matrix')

%EOF
