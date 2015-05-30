function score=score_1VSALL_multiclass(x)
% This is the mean average per class score that is used for caltech and
% CIFAR datasets.
z=sum(x,2);
score=mean(diag(x)./z);

end
