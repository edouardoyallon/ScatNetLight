% Recover options
C=option.Classification.C;
R=option.Classification.random_generator_key;
T_dim_red=option.Classification.Threads_dim_red;
T_classif=option.Classification.Threads_classif;
N=option.Classification.n_run;
D=option.Classification.D;
nAverageKernel=option.Classification.nAverageKernel;
SIGMA_v=option.Classification.SIGMA_v;

% Cross validation takes a lot of time since the algorithms are extremely
% greedy, and consequently it takes a lot of time to get the parameters
% from a validation set.

% cross_validate_max_D=option.Classification.cross_validation_Max_D;
% cross_validate_max_AvgKernel=option.Classification.cross_validation_AvgKernel;
% cross_validate=option.Classification.cross_validation_fraction_train;



tic
%Initialize random generator
if(option.Classification.random_generator_key>0)
    seed_prev=rng(R,'twister');
end

clear res

fprintf('\nGoing in kernel things');
% Launch software for N runs...
for step_run=1:N
   
    
    % Split in training and testing sets
    [index_labels_train,index_labels_test]=split_function();
    
    labels_train=class(index_labels_train);
    labels_test=class(index_labels_test);
    
    trainingData=scattering_representation(index_labels_train,:)';
    testingData=scattering_representation(index_labels_test,:)';
    
    
    % Cross validate C, D, nAverageKernel, SIGMA_v
    % if(cross_validate>=0)
    %    [score,D,nAverageKernel,SIGMA_v,C]=crossvalidate_dataset(trainingData,...
    %    double(labels_train),T_dim_red,T_classif,score_function,cross_validate,...
    % cross_validate_max_D,cross_validate_max_AvgKernel);
    % end
    if(D>0)
        
         %Limit number of threads because of complicated memory issues
    s=matlabpool('size');
    if(s==0)
        matlabpool open
    end
    if(s~=T_dim_red && T_dim_red>0)
        matlabpool close
        matlabpool('local',T_dim_red);
    end
        
        
        outputTrainData=zeros([D*nAverageKernel*numel(unique(labels_train)),size(trainingData,2)],'single');
        outputTestData=zeros([D*nAverageKernel*numel(unique(labels_train)),size(testingData,2)],'single');
        
        data_2_reduce_train=trainingData;
        data_2_reduce_test=testingData;
        
        % Apply the dimensionality reduction
        for j=1:nAverageKernel
            idx_variable_selected=1+(j-1)*D*numel(unique(labels_train)):j*D*numel(unique(labels_train));
            if(T_dim_red>0)
                [outputTrainData(idx_variable_selected,:),outputTestData(idx_variable_selected,:),meta]=pls_multiclass_v2(data_2_reduce_train, data_2_reduce_test, labels_train, unique(labels_train), D);
            else
                [outputTrainData(idx_variable_selected,:),outputTestData(idx_variable_selected,:),meta]=pls_multiclass_v2_noparfor(data_2_reduce_train, data_2_reduce_test, labels_train, unique(labels_train), D);
            end
            idx2remove=meta.select_index(:);
            data_2_reduce_train=data_2_reduce_train(setdiff(1:size(data_2_reduce_train,1),idx2remove),:);
            data_2_reduce_test=data_2_reduce_test(setdiff(1:size(data_2_reduce_test,1),idx2remove),:);
        end
    else
        outputTrainData=trainingData;
        outputTestData=testingData;
    end
    % The bandwith of the kernel is given after renormalization
    SIGMA=mean(sqrt(sum(outputTrainData.^2,1)))*SIGMA_v;
    
    % We build the kernel
    kernel_test = kernelmatrix('rbf',outputTrainData,outputTestData,SIGMA);
    kernel_train = kernelmatrix('rbf',outputTrainData,[],SIGMA);
    [kernel_train,kernel_test]=prepare_kernel_for_svm(kernel_train,kernel_test);% Simple software for libsvm
    
    fprintf('\nNow going into the svm...\n')
    
    s=matlabpool('size');
    if(s~=T_classif)
        if(s==0)
            matlabpool('local',T_classif);
        else
            matlabpool close
            matlabpool('local',T_classif);
        end
    end
    % Gives confusion_matrix
    [confusion_matrix]=SVM_1vsALL_wrapper(labels_train,labels_test, kernel_train,kernel_test,C);score_function(confusion_matrix)
    res(step_run)=score_function(confusion_matrix);
end


timeToClassify=toc;
fprintf(['\nClassified in: ' num2str(timeToClassify) 's\n']);

mean(res)

% Previous random seed
if(option.Classification.random_generator_key>0)
    seed_prev=rng(seed_prev);
end