function y=vector_2_tensor_PCA(x, orig_shape, patch_shape)
    if nargin < 3
        patch_shape = [1 1];
    end

    patch_shape_ = [patch_shape, orig_shape(3), 1];
    n_patches = orig_shape ./ patch_shape_;
    x_patches_shape = [patch_shape_ n_patches];
    x_patches=reshape(x', x_patches_shape);
    y = reverse_extract_patches_even(x_patches);
end