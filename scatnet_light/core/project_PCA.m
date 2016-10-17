function U_tilde = project_PCA(x, PCAfilter)
    [y,s]=tensor_2_vector_PCA(x); 
    sf = size(PCAfilter);
    s(3)=sf(2);
    U_tilde = vector_2_tensor_PCA (y*PCAfilter', s);
end