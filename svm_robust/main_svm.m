   fprintf('\nComputing kernel...')
 
        kernel_train = kernelmatrix('lin',trainingData);
        kernel_test = kernelmatrix('lin',trainingData,testingData);

        fprintf('\nSvm...')


        % Build the kernel - this function is necessary and avoids most of
        % the loss in memory due to kernelization...
        [kernel_train,kernel_test]=prepare_kernel_for_svm(kernel_train,kernel_test);
         [confusion_matrix]=SVM_1vsALL_wrapper(labels_train,labels_test, kernel_train,kernel_test,C);
