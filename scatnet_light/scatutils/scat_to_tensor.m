% SCAT_TO_TENSOR convert scattering output into a vector
%
% Usages
%    out = SCAT_TO_TENSOR(S, keep_space)
%
%
% Input
%    S (cell): The scattering representation to be formatted. It can be a
%    tensor scattering as well.
%    keep_space: if equal to 1 or defined, it keeps the spatial
%    organization of the scattering coefficients
%
% Output
%    out: The scattering representation in the desired format (see below).
%
% Description
%    If the input was a tensor, the output is a tensor of the same size +1.
%

function out = scat_to_tensor(S,keep_space)
if nargin < 2
    keep_space=0;
end

size_signal=size(S{1}.signal{1});
if(keep_space==0)
    tensor_size=size_signal(3:end);
    if(isempty(tensor_size))
        tensor_size=1;
    end
    out=zeros([1,tensor_size]);
else
    tensor_size=size_signal;
    out=zeros([size_signal(1),size_signal(2),1,size_signal(3:end)]);
end


k=1;

for m=1:length(S)
    for p=1:length(S{m}.signal)
        
        size_k=numel(S{m}.signal{p})/prod(tensor_size);
        
        if(keep_space==0)
        
        size_to_reshape=[size_k,tensor_size];
        gen_idx.type = '()';
        gen_idx.subs =repmat({':'},1,length(size_to_reshape));
        gen_idx.subs{1}=k:k+size_k-1;
        
        
        else
            size_to_reshape=[size_signal(1),size_signal(2),size_k,size_signal(3:end)];
        
        gen_idx.type = '()';
        gen_idx.subs =repmat({':'},1,length(size_to_reshape));
        gen_idx.subs{3}=k:k+size_k-1;
        gen_idx.subs{1}=1:size_signal(1);
        gen_idx.subs{2}=1:size_signal(2);
        
        
        end
        reshaped_S=reshape(S{m}.signal{p},size_to_reshape);
        
        out=subsasgn(out,gen_idx,reshaped_S);
        k=k+size_k;
    end
end


if(keep_space==1)
    %topermute=ndims(out);
   % out=permute(out,[2 3 1,4:topermute]);
end
end