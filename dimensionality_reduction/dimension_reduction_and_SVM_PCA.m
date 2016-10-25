%% classification

% recover options
C = option.Classification.C;
SIGMA_v = option.Classification.SIGMA_v;

   
tic;

% split in training and testing sets
q = split_function();

if debug_set
    labels_train = q{1}(1:500);
    labels_test = q{2}(1:500);
else
    labels_train = q{1};
    labels_test = q{2};
end


outputTrainData = S_train;
outputTestData = S_test;

% the bandwith of the kernel is given after renormalization
SIGMA = mean(sqrt(sum(outputTrainData.^2, 1))) * SIGMA_v;

% build the kernel
kernel_test = kernelmatrix('rbf', outputTrainData, outputTestData, SIGMA);
kernel_train = kernelmatrix('rbf', outputTrainData, [], SIGMA);
[kernel_train, kernel_test] = prepare_kernel_for_svm(kernel_train, kernel_test);

% confusion_matrix
[confusion_matrix] = SVM_1vsALL_wrapper(labels_train, labels_test, kernel_train, kernel_test, C);
score_function(confusion_matrix)


timeToClassify = toc;

fprintf('\naccuracy = %d, classified in: %g\n', ans, num2str(timeToClassify));

%% eof
