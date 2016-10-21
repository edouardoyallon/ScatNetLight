% Recover options
C=option.Classification.C;
SIGMA_v=option.Classification.SIGMA_v;

   
tic;
% Split in training and testing sets
q=split_function();

if debug_set
    labels_train=q{1}(1:100);
    labels_test=q{2}(1:100);
    
    %labels_test=labels_train(201:300, 1);
    %labels_train=labels_train(1:200, 1);
else
    labels_train=q{1};
    labels_test=q{2};
end


outputTrainData=S_train;
outputTestData=S_test;

% The bandwith of the kernel is given after renormalization
SIGMA=mean(sqrt(sum(outputTrainData.^2,1)))*SIGMA_v;

% We build the kernel
kernel_test = kernelmatrix('rbf',outputTrainData,outputTestData,SIGMA);
kernel_train = kernelmatrix('rbf',outputTrainData,[],SIGMA);
[kernel_train,kernel_test]=prepare_kernel_for_svm(kernel_train,kernel_test);% Simple software for libsvm

fprintf('\nNow going into the svm...\n')

% Gives confusion_matrix
[confusion_matrix]=SVM_1vsALL_wrapper(labels_train,labels_test, kernel_train,kernel_test,C);
score_function(confusion_matrix)


timeToClassify=toc;
fprintf(['\nClassified in: ' num2str(timeToClassify) 's\n']);

