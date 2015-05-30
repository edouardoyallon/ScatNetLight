function [idx_train,idx_test]=split_equally_by_class(ratio,class)

uni_class=unique(class);
k1=1;
k2=1;
for c=1:numel(uni_class)
    idx=find(class==uni_class(c));
    
    k1end=floor(ratio*numel(idx));
    k2end=numel(idx)-floor(ratio*numel(idx));
    
    rnd_perm_of_coeff=randperm(numel(idx));
    
    idx_train(k1:k1+k1end-1)=idx(rnd_perm_of_coeff(1:k1end));
    idx_test(k2:k2+k2end-1)=idx(rnd_perm_of_coeff(k1end+1:k1end+k2end));
    k1=k1+k1end;
    k2=k2+k2end;
end

end