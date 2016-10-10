function U_tilde_j = PCA_concat(S_j, U_j)
    
    U_format = format_scat(U_j);
    U_tilde_j = [U_format;  S_j];
end