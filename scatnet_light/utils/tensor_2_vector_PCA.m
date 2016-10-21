function [y,s]=tensor_2_vector_PCA(x, patch_shape)
     s=size(x);
    y=permute(x,[1,2,4,3]);
    y2=reshape(y,numel(y)/size(y,ndims(y)),size(y,ndims(y)));
    if nargin < 2
        patch_shape_ = [1, 1, size(x, 3), 1];
    else
        patch_shape_ = [patch_shape, size(x, 3), 1];
    end
    
    patches = extract_patches_even(x, patch_shape_);
    new_shape = prod(reshape(size(patches),  [], 2), 1);
    y = reshape(patches, new_shape)';
end

