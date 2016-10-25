function U_tilde = project_PCA(x, PCAfilter, mu, et, patch_size)
    [y,s]=tensor_2_vector_PCA(x, patch_size); 
    y = bsxfun(@minus, y, mu); %
    %y = standardize_feature(y, mu, et);
    projected  = y * PCAfilter; 
    
    patch_size_ = [patch_size s(3) 1];
    out_shape_per_component = s ./ patch_size_;
    out_shape = out_shape_per_component;
    out_shape(3) = size (PCAfilter, 2);
    
    U_tilde = vector_2_tensor_PCA (projected, out_shape, [1 1]);
end