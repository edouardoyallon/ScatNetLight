function U = compute_J_scale(x, filters, J, second_only)
    filters_j = select_filters_at_J (filters, J);
    
    filters_j{1}.meta.Q=1;
    U{1}.signal{1} = x;
	U{1}.meta.j = zeros(0,1);
	U{1}.meta.q = zeros(0,1);
    U{1}.meta.resolution=0;
    [~, U_j_1] = wavelet_layer_1_2d (U{1}, filters_j{1}) ;
    U_j_1 = modulus_layer(U_j_1);
    
    s1 = size(U_j_1.signal{end},1);
    s2 = size(U_j_1.signal{end},2);
    s4=size(U_j_1.signal{end},ndims(U_j_1.signal{end}));
    
    s3p=numel(U_j_1.signal{end})/(s1*s2*s4);
    
    if(J>1)
        [~, U_j_2] = wavelet_layer_2_2d (U_j_1, filters_j{2}) ;
        s3= numel(U_j_2.signal{1})/(s1*s2*s4);

        if second_only
        	U = cat(3, reshape(U_j_2.signal{1}, [s1, s2, s3,s4]));
        else 
            U = cat(3, reshape(U_j_2.signal{1}, [s1, s2, s3,s4]), ...
                reshape(U_j_1.signal{end}, [s1, s2, s3p,s4]));
        end
    else
       U=reshape(U_j_1.signal{end}, [s1, s2, s3p,s4]);
    end
end