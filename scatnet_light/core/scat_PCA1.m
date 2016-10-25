
function S = scat_PCA1(x, filters, PCA_filters, PCA_evals, eps_ratio, J, recompute, patch_size)
    U_tilde = cell(1,J);
    for j = 1 : J
        if recompute
            fprintf ('\t\t(compute scale %d)\n', j)
            U_j = compute_J_scale(x, filters, j);
        else
            U_j = x{j};
        end
        cs = cumsum (PCA_evals{j}) / sum (PCA_evals{j});
        keep = cs < (1. - eps_ratio);
        PCA_cut = PCA_filters{j}(:, keep);
        fprintf ('\t\t(project pca at scale %d (dims = %s))\n', j, num2str(size (PCA_cut)))
        U_tilde{j} = project_PCA(U_j, PCA_cut, patch_size);
        clear U_j
        U_tilde{j}=abs(U_tilde{j});
        s=wavelet_2d(U_tilde{j},filters);
        %s = U_tilde{j};
        s2=size(s,ndims(s));
        s1=numel(s)/s2;
        U_tilde{j} = reshape(s,[s1,s2])';
        clear s
    end
    
    S = cell2mat(U_tilde)';
end
