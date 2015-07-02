% MORLET_3D
% Computes the 3D ellipsoidal Morlet wavelet given a set of parameters.
%
% Usage:
%   psi = MORLET_3D(N, sigma, slant, xi, angle_axis)
%
% Inputs:
%   1.) N (numeric): 1x3 vector [N1,N2,N3] indicating the size of the
%       wavelet.
%   2.) sigma (numeric): Positive real number specifying the width of the
%       anisotropic (elliptic) Gaussian envelope.
%   3.) slant (numeric): Eccentricity (along the z-axis) of the elliptic
%       envelope.
%   4.) xi (numeric): (0,0,xi) is the frequency peak of the wavelet.
%   5.) angle_axis (numeric): 1x3 vector that rotates the Morlet wavelet to 
%       have radial symmetry about angle_axis.
%
% Outputs:
%
%   1.) psi (numeric): A matrix of size N representing the Morlet wavelet
%       in the spatial domain.
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

function psi = morlet_3d(N, sigma, slant, xi, axis_u)

% Mesh grid
[x,y,z] = meshgrid(1:N(1),1:N(2),1:N(3));
x = x - ceil(N(1)/2) - 1;
y = y - ceil(N(2)/2) - 1;
z = z - ceil(N(3)/2) - 1;

% Rotation matrix
R = rotation_a_onto_b_3d([0,0,1],axis_u);

% Rotate the mesh grid
x = reshape(x,1,numel(x));
y = reshape(y,1,numel(y));
z = reshape(z,1,numel(z));
Rxyz = R*[x;y;z];
Rx = Rxyz(1,:);
Ry = Rxyz(2,:);
Rz = Rxyz(3,:);
Rx = reshape(Rx,N);
Ry = reshape(Ry,N);
Rz = reshape(Rz,N);

% Gaussian part
g = exp(-(Rx.^2 + Ry.^2 + (Rz/slant).^2)/(2*sigma^2));

% Oscillating part
o = g .* exp(1i*xi*Rz);

% Morlet wavelet with zero average
K = sum(o(:))/sum(g(:));
psi = o - K*g;

% Normalize so that the maximum of the Fourier modulus is bounded by one
psi = (1/(sqrt(8)*pi^(3/2)*slant*sigma^3)) * psi;

end