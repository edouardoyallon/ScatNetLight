function [score,D,nAverageKernel,SIGMA_v,C]=crossvalidate_dataset(features,labels,T_dim_red,T_classif,score_function,ratio_2_use,maxD_real,maxAvgKernel_real)%[D,nAverageKernel,SIGMA_v,C]=crossvalidate_dataset(features,labels,score_function)
% This function takes more than 10 days before it finished and crashes sometimes...
% I let this function in case people are OK to wait. However, similarly to
% deepnet, we fix the parameters for the 4 datasets and it still works.


maxD=min([size(features)*ratio_2_use,maxD_real]);
D_2_try=floor(linspace(min(maxD,5),maxD,4));
nAverageKernel_2_try=1:maxAvgKernel_real;

C_2_try=[1 5 10 25 50];
SIGMA_v_2_try=[0.8 0.9 1 1.1 1.2];

n_run_cross_valid=5;
COUNTER=0;
% features

for n_count=1:n_run_cross_valid
    [idx_train,idx_test]=split_equally_by_class(ratio_2_use,labels);
    
    trainingData=features(:,idx_train);
    testingData=features(:,idx_test);
    labels_train=labels(idx_train);
    labels_test=labels(idx_test);
    
    for D_count=1:numel(D_2_try)
        D=D_2_try(D_count);
        outputTrainData=zeros([D*max(nAverageKernel_2_try)*numel(unique(labels_train)),size(trainingData,2)],'single');
        outputTestData=zeros([D*max(nAverageKernel_2_try)*numel(unique(labels_train)),size(testingData,2)],'single');
        
        data_2_reduce_train=trainingData;
        data_2_reduce_test=testingData;
        
        for nAverageKernel_count=1:numel(nAverageKernel_2_try)
            j=nAverageKernel_count;
            idx_variable_selected=1+(j-1)*D*numel(unique(labels_train)):j*D*numel(unique(labels_train));
            if(T_dim_red>0)
                [outputTrainData(idx_variable_selected,:),outputTestData(idx_variable_selected,:),meta]=pls_multiclass_v2(data_2_reduce_train, data_2_reduce_test, labels_train, unique(labels_train), D);
            else
                [outputTrainData(idx_variable_selected,:),outputTestData(idx_variable_selected,:),meta]=pls_multiclass_v2_noparfor(data_2_reduce_train, data_2_reduce_test, labels_train, unique(labels_train), D);
            end
            idx2remove=meta.select_index(:);
            data_2_reduce_train=data_2_reduce_train(setdiff(1:size(data_2_reduce_train,1),idx2remove),:);
            data_2_reduce_test=data_2_reduce_test(setdiff(1:size(data_2_reduce_test,1),idx2remove),:);
            
            for SIGMA_v_count=1:numel(SIGMA_v_2_try)
                SIGMA_v=SIGMA_v_2_try(SIGMA_v_count);
                SIGMA=mean(sqrt(sum(outputTrainData.^2,1)))*SIGMA_v;
                
                kernel_test = kernelmatrix('rbf',outputTrainData,outputTestData,SIGMA);
                kernel_train = kernelmatrix('rbf',outputTrainData,[],SIGMA);
                
                [kernel_train,kernel_test]=prepare_kernel_for_svm(kernel_train,kernel_test);
                
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
                for C_count=1:numel(C_2_try)
                    C=C_2_try(C_count);
                    COUNTER=COUNTER+1;
                    fprintf('done %f',COUNTER/(numel(C_2_try)*numel(D_2_try)*numel(SIGMA_v_2_try)*numel(nAverageKernel_2_try)*n_run_cross_valid))
                    [confusion_matrix]=SVM_1vsALL_wrapper(labels_train,labels_test, kernel_train,kernel_test,C);%score_function(confusion_matrix)
                    score(n_count,C_count,D_count,SIGMA_v_count,nAverageKernel_count)=score_function(confusion_matrix);
                end
            end
        end
    end
end

score2=(sum(score,1));
[~,I] = max(score2(:));
[I1,I2,I3,I4,I5] = ind2sub(size(score2),I);


C=C_2_try(I2);
if(I3==numel(D_2_try))
    D=D_2_try(I3);
else
    D=maxD_real;
end
SIGMA_v=SIGMA_v_2_try(I4);
nAverageKernel=nAverageKernel_2_try(I5);
end
