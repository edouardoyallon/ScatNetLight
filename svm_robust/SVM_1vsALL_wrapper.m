function [confusion_matrix]=SVM_1vsALL_wrapper(class_train,class_test, kernel_train,kernel_test,C)%,phi)
% Train a 1VSALL SVM
% Class can be in the order you want, you don't have to sort them, it does
% not have to begin by 1 to N, it just needs to be numbers
%
% It returns the confusion_matrix so that you can chose which score you
% want to apply
%
% This is the function you want to optimize

% Number of different class

% 
% if(nargin>5)
%     isOk=1;
%     phiT=phi;
% else
%     isOk=0;
%     phiT=0;
% end

if(size(class_train,1)>size(class_train,2))
    class_train=class_train';
end

if(size(class_test,1)>size(class_test,2))
    class_test=class_test';
end


index_of_class=unique(class_train);

option_svm=['-s 0 -t 4 -q -c ' num2str(C)];


  model=cell(numel(index_of_class),1);
  decision=zeros(numel(index_of_class),numel(class_test),'single');

for k=1:numel(index_of_class)%c=index_of_class
%     t=getCurrentTask();
%     t=t.ID;
%     pause(min(5*s*t));
    c=index_of_class(k);
labels_train=(c==class_train);
    labels_test=(c==class_test);
    
   
    % Train SVM
    model{k}=svmtrain_inplace(double(labels_train),kernel_train,option_svm);
    
    
    o=double(labels_test);
     
    
    % Test SVM
    [~,~,decision(k,:)]=svmpredict_inplace(o,kernel_test,model{k});
    
   % Here, we need to use a for loop because the heap is too small
   
    % Internally, libSVM treats the first class as "-1" - they said it's
    % not a bug, ... -.-'
    if(labels_train(1)~=1)
        decision(k,:)=-decision(k,:);
    %    sign_decision(k)=-1;
    else
     %   sign_decision(k)=1;
    end
    
end

% 
% 
% if(isOk)
% w=zeros(numel(index_of_class),size(phiT,1));
%     bias=zeros(numel(index_of_class),1);
% for k=1:numel(index_of_class)
%      w(k,:)=sign_decision(k)*(model{k}.sv_coef' * phiT(:,model{k}.SVs)');
%    bias(k,:)=-sign_decision(k)*model{k}.rho;
%     end
% end
%   s=matlabpool('size');
% if(isOk)
% support_vector.w=w;
% support_vector.bias=bias;
% else
%     support_vector=struct;
% end
%  

% Find class in wich an element belongs to
[~,decision]=max(decision);

k=numel(index_of_class);



for c1=1:k
    for c2=1:k
    confusion_matrix(c2,c1)=sum(decision==c1 & class_test==index_of_class(c2));
    end
end




end