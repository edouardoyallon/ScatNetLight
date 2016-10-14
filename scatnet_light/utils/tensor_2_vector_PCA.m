function [y,s]=tensor_2_vector_PCA(x)
s=size(x);
y=permute(x,[1,2,4,3]);
y=reshape(y,numel(y)/size(y,ndims(y)),size(y,ndims(y)));

end

