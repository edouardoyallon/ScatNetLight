% MORLET_1D
% Computes 1D Morlet wavelet given a set of parameters
%
% Usage:
%   psi = MORLET_1D(N, sigma, xi)
%
% Inputs:
%   1.) N (integer): Positive integer indicating the signal length of the
%       wavelet.
%   2.) sigma (numeric): Positive real number specifying the width of the
%       Gaussian envelope.
%   3.) xi (numeric): The frequency peak of the wavelet.
%
% Outputs:
%   1.) psi (numeric): A vector of length N representing the Morlet wavelet
%       in the spatial (time) domain.
%
% This file is part of ScatNetLight
% Author: Matthew Hirn
% email: mhirn@msu.edu

function psi = morlet_1d(N, sigma, xi)

% Sample points
x = 1:N;
x = x - ceil(N/2) - 1;

% Gaussian part
g = exp(-(x.^2)./(2*sigma^2));

% Gaussian modulated oscillating wave
o = g .* exp(1i * xi * x);

% Morlet wavelet with zero average
K = sum(o(:))/sum(g(:));
psi = o - K*g;

% Normalize so that the maximum of the Fourier modulus is bounded by one
psi = (1/(sigma*sqrt(2*pi))) * psi;

end
