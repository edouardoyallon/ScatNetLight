function [K_train,K_test]=prepare_kernel_for_svm(k_train,k_test)



 K_train=zeros(size(k_train,1)+1,size(k_train,2),'single');
 K_train(1,:)=single(1:size(k_train,1));
 K_train(2:end,:)=k_train;
 

  K_test=zeros(size(k_test,1)+1,size(k_test,2),'single');
 K_test(1,:)=single(1:size(k_test,2));
 K_test(2:end,:)=k_test;
 
end