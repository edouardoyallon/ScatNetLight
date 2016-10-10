
function [S_j, U_tilde_j] = scat_PCA_previous (x, filters, PCA_filters, J, S_J_prev)
    S_tilde = haar_lp (S_J_prev);
    if (J ~= 1) 
        S_tilde = S_tilde(1:2:end); 
    end % subsampling
    
    filters_j = select_filters_at_J (filters, J);

%     U_j_1 = wavelet_2d(x, filters_j{1});
%     for i = 1 : 
%         1er cas scale = j
%         stored  in U
%         else
%             apply ca :
%             U_j_2 = wavelet_2d(abs (U_j_1), filters_j{2});
%             for all
%                 store in U
%             end
%     end
%         U_tilde_j = PCA_concat (S_tilde, U_j_2);
    filters_j{1}.meta.Q=1;
    U{1}.signal{1} = x;
	U{1}.meta.j = zeros(0,1);
	U{1}.meta.q = zeros(0,1);
    U{1}.meta.resolution=0;
    [~, U_j_1] = wavelet_layer_2d (U{1}, filters_j{1}) ;
    U_j_1 = modulus_layer(U_j_1);
    [~, U_j_2] = wavelet_layer_2d (U_j_1, filters_j{2}) ;
    
    % Concatenate U_j_1 at scale j and U_j_2
    
    S_j = PCA_filters * U_tilde_j;
end
