% GAUSSIAN_3D
% Computes a 3D Gaussian
%
% Usage:
%   g = GAUSSIAN_3D(N, sigma)
%
% Inputs:
%   1.) N (numeric): 1x3 vector with the dimension of the Gaussian.
%   2.) sigma (numeric): Positive real number setting the width of the
%       Gaussian.
%
% Outputs:
%   1.) g (numeric): A 3D matrix of size N with the Gaussian centered in
%       the middle.
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

function g = gaussian_3d(N, sigma)

% Mesh grid
[x,y,z] = meshgrid(1:N(1),1:N(2),1:N(3));
x = x - ceil(N(1)/2) - 1;
y = y - ceil(N(2)/2) - 1;
z = z - ceil(N(3)/2) - 1;

% Gaussian
g = (1/(sqrt(8)*pi^(3/2)*sigma^3)) * exp(-(x.^2+y.^2+z.^2)./(2*sigma^2));

end