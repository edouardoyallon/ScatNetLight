function U_tilde = project_PCA(x, PCAfilter, mu, et)

    [y,s]=tensor_2_vector_PCA(x); 
    y = standardize_feature(y, mu, et);
    
    sf = size(PCAfilter);
    s(3)=sf(2);
    U_tilde = vector_2_tensor_PCA (y*PCAfilter, s);
end