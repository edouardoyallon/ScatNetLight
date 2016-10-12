% Recover options
C=option.Classification.C;
%R=option.Classification.random_generator_key;
%T_dim_red=option.Classification.Threads_dim_red;
%T_classif=option.Classification.Threads_classif;
%N=option.Classification.n_run;
%D=option.Classification.D;

%nAverageKernel=option.Classification.nAverageKernel;
SIGMA_v=option.Classification.SIGMA_v;


tic


fprintf('\nGoing in kernel things');
    
    % Split in training and testing sets
    [index_labels_train,index_labels_test]=split_function();
    
    labels_train=class(index_labels_train);
    labels_test=class(index_labels_test);
    
    trainingData=scattering_representation(index_labels_train,:)';
    testingData=scattering_representation(index_labels_test,:)';
    
    
    outputTrainData=trainingData;
    outputTestData=testingData;
 %   end
    % The bandwith of the kernel is given after renormalization
    SIGMA=mean(sqrt(sum(outputTrainData.^2,1)))*SIGMA_v;
    
    % We build the kernel
    kernel_test = kernelmatrix('rbf',outputTrainData,outputTestData,SIGMA);
    kernel_train = kernelmatrix('rbf',outputTrainData,[],SIGMA);
    [kernel_train,kernel_test]=prepare_kernel_for_svm(kernel_train,kernel_test);% Simple software for libsvm
    
    fprintf('\nNow going into the svm...\n')
    
 
    % Gives confusion_matrix
    [confusion_matrix]=SVM_1vsALL_wrapper(labels_train,labels_test, kernel_train,kernel_test,C);score_function(confusion_matrix)
    res=score_function(confusion_matrix);


timeToClassify=toc;
fprintf(['\nClassified in: ' num2str(timeToClassify) 's\n']);

res

