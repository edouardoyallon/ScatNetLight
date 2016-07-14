% GAUSSIAN_1D
% Computes a 1D Gaussian with integral equal to one
%
% Usage:
%   g = GAUSSIAN_1D(N, sigma)
%
% Inputs:
%   1.) N (integer): The length of the Gaussian signal
%   2.) sigma (numeric): Positive real number settings the width of the
%       Gaussian.
%
% Outputs:
%   1.) g (numeric): A 1D vector of length N with the Gaussian centered in
%       the middle.
%
% This file is part of ScatNetLight
% Author: Matthew Hirn
% Email: mhirn@msu.edu

function g = gaussian_1d(N, sigma)

% Sample points
x = 1:N;
x = x - ceil(N/2) - 1;

% Gaussian
g = (1/(sigma*sqrt(2*pi))) * exp(-(x.^2)./(2*sigma^2));

end