function tens = reverse_extract_patches_even(patches)
    sz = size (patches);
    perm = reshape(reshape(1:length(sz), [], 2)', [], 1);    
    permuted = permute(patches, perm);
    orig_shape = prod (reshape(sz, [], 2), 2)';
    tens = reshape(permuted, orig_shape);
    
end