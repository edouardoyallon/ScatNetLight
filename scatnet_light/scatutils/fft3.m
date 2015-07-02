% FFT3
% Computes the 3D Fast Fourier Transform
%
% Usage:
%   Y = FFT3(X)
%
% Inputs:
%   1.) X (numeric): N-D matrix, N >= 3.
%
% Outputs:
%   1.) Y (numeric): Fourier transform of X. Y is the same size as X. If X
%       is an N-D matrix, N > 3, then Y is the Fourier transform of
%       X(:,:,:,ind) for each possible index.
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

function Y = fft3(X)

Y = X;
for p=1:3
    Y = fft(Y,[],p);
end

end