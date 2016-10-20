
function S_j = scat_PCA2(x, filters, PCA_filters, PCA_evals, eps_ratio, J, mu, D)
  
S_j = x;

for j=1:J
    fprintf ('h filtering at scale %d...\n', j)
    S_j_tilde = haar_lp(S_j, j>2);
     
    fprintf ('compute scale %d...\n', j)
    U_j = compute_J_scale(x, filters, j);
    
    Z_j = cat(3, U_j, S_j_tilde);
    
    [Z_j_vect,sz]=tensor_2_vector_PCA(Z_j);
    clear U_j
    
    clear S_j_tilde
    fprintf ('standardization at scale %d...\n', j)
    
    Z_j_vect=standardize_feature(Z_j_vect, mu{j}, D{j});
    S_j=vector_2_tensor_PCA(Z_j_vect*PCA_filters{j}, sz);
end
end








