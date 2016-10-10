
function [S_j, U_tilde_j] = scat_PCA_previous (x, filters, PCA_filters, J, S_J_prev)
    S_tilde = haar_lp (S_J_prev);
    if (J ~= 1) 
        S_tilde = S_tilde(1:2:end); 
    end % subsampling
    
    filters_j = select_filters_at_J (filters, J);
    U_j_1 = wavelet_2D(x, filters_j{1});
    U_j_2 = wavelet_2D(abs (U_j_1), filters_j{2});
    U_tilde_j = PCA_concat (S_tilde, U_j_2);
    S_j = PCA_filters * U_tilde_j;
end
