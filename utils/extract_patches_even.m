function patches = extract_patches_even(data, patch_shape)

    n_patches = size(data) ./ patch_shape;
    new_shape = [patch_shape;n_patches];
    new_shape = new_shape(:)';
    
    reshaped = reshape(data, new_shape);
    perm = reshape(reshape(1:length(new_shape), 2, [])', [], 1);
    permuted = permute(reshaped, perm);
    
    patches = permuted;
end