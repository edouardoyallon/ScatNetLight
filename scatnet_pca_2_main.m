 % This is the main script to compute a scattering representation, given
% options.

% If set to 1, this variable recomputes precomputed features for a given
% option.
recompute=1;

% Clear every previous batch of the works
clear jobs
fprintf('Load options...\n');
% Folders to save data are created according to the given options
createjobfolder(option,mergestruct(option.Exp));
nameJobFile=getnamejobfile(option,0,mergestruct(option.Exp));
savepar(nameJobFile,'option',option);

% Create the config specific to the dataset
[class,getImage,score_function,split_function,Wop,Wop_color,filt_opt,filt_opt_color]=recover_dataset(option);

x_train=getImage('train');
x_test=getImage('test');


% traning set!
x_train = single(rgb2yuv(x_train));
x_test = single(rgb2yuv(x_test));
PCA_filters={};
S_prev={};

% Train procude on the training set
for j=1:max_J
    if(j<max_J)
        [S,U_tilde]=scat_PCA(x,Wop,PCA_filters,j,U_tilde_prev);
        U_tilde_prev=U_tilde;
        
        [U_tilde,mu,D]=standardize(U_tilde);
    
        PCA_filters{j+1}=pca(U_tilde);
        PCA_filters{j+1} = apply_renorm(D,PCA_filters{j+1});
    
    else
        S=scat_PCA(x,Wop,PCA_filters,j);
    end
    
    % Maybe one should save PCA_filters?
end


S_train = S;
S_test = scat_PCA(x_test,Wop,PCA_filters,J_max);

[S_train,mu,D]=standardize(S_train);
S_test=standardize(S_test,mu,D);

timeScat=toc;
fprintf(['\nScat layer processed in ' num2str(timeScat) 's\n']);

k=1;
tic

% Reduce dimension + Classification framework
dimension_reduction_and_SVM_PCA