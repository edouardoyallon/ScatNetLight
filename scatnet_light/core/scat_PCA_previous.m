
function S_j = scat_PCA_previous (x, Wop, PCA_filters, J, S_J_prev)
    S_tilde = haar_lp (S_J_prev);
    if (J ~= 1) 
        S_tilde = S_tilde[1:2:end]; 
    end % subsampling
    
    filters_j = select_j_filters (Wop, J);
    U_j_1 = wavelet_2D(x, filters_j{1});
    U_j_2 = wavelet_2D(abs (U_j_1), filters_j{2});
    Z = PCA_concatenate (S_tilde, U_j_2);
    S_j = PCA_filters * Z;
end
