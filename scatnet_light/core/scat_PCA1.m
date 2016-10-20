
function S = scat_PCA1(x, filters, PCA_filters, PCA_evals, eps_ratio, J, mus, et, recompute)
    U_tilde = cell(1,J-1);
    for j = 2 : J
        if recompute
            fprintf ('\tscat_pca1 -> compute scale %d\n', j)
            U_j = compute_J_scale(x, filters, j);
        else
            U_j = x{j};
        end
        variance = sum (PCA_evals{j});
        threshold = variance * eps_ratio;
        PCA_cut = PCA_filters{j}(:, PCA_evals{j} > threshold);
        fprintf ('\tscat_pca1 -> project pca at scale %d (dims = %s)\n', j, num2str(size (PCA_cut)))
        U_tilde{j-1} = project_PCA(U_j, PCA_cut, mus{j}, et{j});
        clear U_j
        U_tilde{j-1}=abs(U_tilde{j-1});
        s=wavelet_2d(U_tilde{j-1},filters);
        %s = U_tilde{j};
        fprintf ('\tscat_pca1 -> reshape at scale %d\n\n', j)
        s2=size(s,ndims(s));
        s1=numel(s)/s2;
        U_tilde{j-1} = reshape(s,[s1,s2])';
        clear s
    end
    
    S = cell2mat(U_tilde)';
end
