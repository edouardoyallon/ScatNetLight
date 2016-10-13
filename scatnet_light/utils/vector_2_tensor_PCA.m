function y=vector_2_tensor_PCA(x,s)
s1 =s([1,2,4,3]);
y=reshape(x,s1);
y=permute(y,[1,2,4,3]);
end