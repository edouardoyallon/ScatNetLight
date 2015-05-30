function x=get_half_angles2(x,dim_along_angles)
    L=size(x,dim_along_angles);
    x(:,:,(L+1):(2*L),:,:,:,:,:,:,:,:)=conj(x(:,:,1:L,:,:,:,:,:,:,:,:));% This is not... optimal! but it works.
end