function x=periodize_nd_along_k(x,n_block,k)
% Compute sum n_block of x, and keep dimension - it allows a downsample in
% fourier domain

	N = size(x,k);
    s=size(x);
    sf=s;
    sf(k)=N/n_block;
    s(k+1:end+1)=s(k:end);
    s(k+1)=n_block;
    s(k)=N/n_block;
    x=reshape(x,s);
    x=sum(x,k+1);
    x=reshape(x,sf);
 
end