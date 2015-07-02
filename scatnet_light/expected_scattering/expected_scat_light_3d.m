% EXPECTED_SCAT_LIGHT_3D 
% Expected (mean) scattering for the 3D scattering transform as outputted
%   from ScatNet Light.
%
% Usage
%   EU = EXPECTED_SCAT_LIGHT_ROTO_2D(U,scat_type,p)
%
% Input
%   U (cell): A cell in which U{m+1} are the m level scattering
%       coefficients of a 2D signal, computed with the scatnet light 
%       software. U can only have zero, one, or two layers.
%   scat_type (string): t/tr/tr_nonsepa
%   p (integer): Computes the pth moment (default: p=1)
%
% Output
%   EU (cell): A cell in which EU{m+1} are the m level expected (mean) 
%       scattering coefficients of a 3D signal.
%
% Description
%   Takes in a set of 2D scattering coefficients and returns the
%   expected (mean) scattering coefficients. In particular, the expectation
%   is taken along translations (space) and rotations (angles).
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

function EU = expected_scat_light_3d(U,scat_type,p)

% Initialize
if nargin < 3
    p = 1;
end
M = length(U)-1;
EU = cell(1,M+1);
num_sig = size(U{1}.signal{1},4);

% Layer zero
EU{1}.signal = zeros(num_sig,1);
for i=1:num_sig
    sig = U{1}.signal{1}(:,:,:,i);
    EU{1}.signal(i,1) = (2^(-p*U{1}.meta.resolution(1)))*mean(sig(:).^p);
end
EU{1}.meta.j = U{1}.meta.j;
EU{1}.meta.resolution = U{1}.meta.resolution;
EU{1}.meta.layer = 0;
EU{1}.meta.moment = p;

% Layer one
if M > 0
    
    % Compute expected scattering for 1st layer
    J1 = length(U{2}.signal);
    EU{2}.signal = zeros(num_sig,J1);
    for j1=1:J1
        for i=1:num_sig
            sig = U{2}.signal{j1}(:,:,:,:,i);
            EU{2}.signal(i,j1) = (2^(-p*2*U{2}.meta.resolution(j1)))*mean(sig(:).^p);
        end
    end
    
    % Fill in meta information
    EU{2}.meta.j = U{2}.meta.j;
    EU{2}.meta.resolution_t = U{2}.meta.resolution;
    EU{2}.meta.resolution_r = zeros(1,J1);
    EU{2}.meta.layer = 1;
    EU{2}.meta.moment = p;
    
end

end