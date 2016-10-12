
function S = scat_PCA1(x, filters, PCA_filters, J)

U_tilde = cell(1,J);
    for j = 1 : J
        U_j = compute_J_scale(x, filters, j);
        U_tilde{j} = project_PCA(U_j, PCA_filters{j});
        U_tilde{j}=abs(U_tilde{j});
        s=wavelet_2d(U_tilde{j},filters);
                s2=size(s,ndims(s));
        s1=numel(s)/s2;
        U_tilde{j} = reshape(s,[s1,s2])';
    end
    
    S = cell2mat(U_tilde)';
end
