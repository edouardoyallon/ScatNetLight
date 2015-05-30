function [feature,mF,stdF]=standardize_feature(feature,mF,stdF) 

if(nargin<3)
mF=mean(feature);
        stdF=std(feature);
        stdF(stdF==0)=1;
end

        
        feature=bsxfun(@minus,feature,mF);
        feature=bsxfun(@rdivide,feature,stdF);
        
end