function [y,s]=tensor_2_vector_PCA(x)
s=size(x);
x=permute(x,[1,2,4,3]);
y=reshape(x,numel(x)/size(x,ndims(x)),size(x,ndims(x)));

end

