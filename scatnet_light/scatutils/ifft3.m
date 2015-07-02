% IFFT3
% Computes the 3D Inverse Fast Fourier Transform
%
% Usage:
%   Y = IFFT3(X)
%
% Inputs:
%   1.) X (numeric): N-D matrix, N >= 3.
%
% Outputs:
%   1.) Y (numeric): Inverse Fourier transform of X. Y is the same size as 
%       X. If X is an N-D matrix, N > 3, then Y is the inverse Fourier 
%       transform of X(:,:,:,ind) for each possible index.
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

function Y = ifft3(X)

Y = X;
for p=1:3
    Y = ifft(Y,[],p);
end

end