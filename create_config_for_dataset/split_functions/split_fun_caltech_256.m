function [labels_train,labels_test]=split_fun_caltech_256(class,n)
% Function that split the dataset for caltech256 in a training set and a
% testing set
% The clutter class is removed

if(nargin<2)
	n=30;
end

classes=unique(class);

labels_train=[];
labels_test=[];
% 257 for CLUTTER CLASS)
for c=1:numel(classes)-1
    list_c=find(class==classes(c));
    rand_c=randperm(numel(list_c));
    labels_train=[labels_train;list_c(rand_c(1:n))];
    labels_test=[labels_test;list_c(rand_c(n+1:end))];
end
end
