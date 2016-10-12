function y=vector_2_tensor_PCA(x,s)
x=permute(x,[1,2,4,3]);
y=reshape(x,s);
end