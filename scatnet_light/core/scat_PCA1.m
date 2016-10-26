
function S = scat_PCA1(x, filters, PCA_filters, PCA_evals, eps_ratio, J, ...
    patch_size, second_only)
    if second_only
        min_J = 2;
          U_tilde = cell(1, J - 1);
        
    else 
        min_J = 1;
        U_tilde = cell(1, J);
    end
    
    for j = min_J : J
        fprintf ('\t(compute scale %d)\n', j)
        U_j = compute_J_scale(x, filters, j, second_only);
        cs = cumsum (PCA_evals{j}) / sum (PCA_evals{j});
        keep = cs < (1. - eps_ratio);
        PCA_cut = PCA_filters{j}(:, keep);
        fprintf ('\t(project pca at scale %d (dims = %s))\n', j, ...
            num2str(size (PCA_cut)))
        U_tilde_tmp = project_PCA(U_j, PCA_cut, patch_size);
        clear U_j
        U_tilde_tmp = abs(U_tilde_tmp);
        s = wavelet_2d(U_tilde_tmp, filters);
        s2 = size(s, ndims(s));
        s1=numel(s) / s2;
        
        if second_only
            U_tilde{j - 1} = reshape(s, [s1,s2])';
        else
            U_tilde{j} = reshape(s, [s1,s2])';
        end
        clear s
    end
    
    S = cell2mat(U_tilde)';
end
