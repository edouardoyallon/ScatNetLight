
function S = scat_PCA1(x, filters, PCA_filters, PCA_evals, eps_ratio, J)
    U_tilde = cell(1,J);
    for j = 1 : J
        fprintf ('\tscat_pca1 -> compute scale %d\n', j)
        U_j = compute_J_scale(x, filters, j);
        variance = sum (PCA_evals{j});
        threshold = variance * eps_ratio;
        PCA_cut = PCA_filters{j}(:, PCA_evals{j} > threshold);
        fprintf ('\tscat_pca1 -> project pca at scale %d (dims = %s)\n', j, num2str(size (PCA_cut)))
        U_tilde{j} = project_PCA(U_j, PCA_cut);
        clear U_j
        U_tilde{j}=abs(U_tilde{j});
        s=wavelet_2d(U_tilde{j},filters);
        %s = U_tilde{j};
        fprintf ('\tscat_pca1 -> reshape at scale %d\n\n', j)
        s2=size(s,ndims(s));
        s1=numel(s)/s2;
        U_tilde{j} = reshape(s,[s1,s2])';
        clear s
    end
    
    S = cell2mat(U_tilde)';
end
