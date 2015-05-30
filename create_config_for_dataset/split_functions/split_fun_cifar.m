function [labels_train,labels_test]=split_fun_cifar()
% Split in a training and testing set CIFAR10/CIFAR100

labels_train=1:50000;
labels_test=50001:60000;
end