% EXPECTED_SCAT_LIGHT_2D 
% Expected (mean) scattering for the 2D scattering transform as outputted
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
%       scattering coefficients of a 2D signal.
%
% Description
%   Takes in a set of 2D scattering coefficients and returns the
%   expected (mean) scattering coefficients. In particular, the expectation
%   is taken along translations (space) and rotations (angles).
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

function EU = expected_scat_light_2d(U,scat_type,p)

% Initialize
if nargin < 3
    p = 1;
end
M = length(U)-1;
EU = cell(1,M+1);
num_sig = size(U{1}.signal{1},3);

% Layer zero
EU{1}.signal = zeros(num_sig,1);
for i=1:num_sig
    sig = U{1}.signal{1}(:,:,i);
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
            sig = U{2}.signal{j1}(:,:,:,i);
            EU{2}.signal(i,j1) = (2^(-p*U{2}.meta.resolution(j1)))*mean(sig(:).^p);
        end
    end
    
    % Fill in meta information
    EU{2}.meta.j = U{2}.meta.j;
    EU{2}.meta.resolution_t = U{2}.meta.resolution;
    EU{2}.meta.resolution_r = zeros(1,J1);
    EU{2}.meta.layer = 1;
    EU{2}.meta.moment = p;
    
end

% Layer two
if M > 1
    
    % Initialize fields
    EU{3}.signal = [];
    EU{3}.meta.j = [];
    EU{3}.meta.theta2_minus_theta1 = [];
    if ~strcmpi(scat_type,'t')
        EU{3}.meta.k2 = [];
    end
    EU{3}.meta.resolution_t = [];
    EU{3}.meta.resolution_r = [];
    EU{3}.meta.layer = 2;
    EU{3}.meta.moment = p;
    
    % Reshape 2nd layer U tensors
    J2 = length(U{3}.signal);
    for j2=1:J2
        switch lower(scat_type)
            case 't'
                U{3}.signal{j2} = reshape_translation_exp(U{3}.signal{j2});
            case 'tr'
                U{3}.signal{j2} = reshape_rototranslation_separable_exp(U{3}.signal{j2});
            case 'tr_nonsepa'
                U{3}.signal{j2} = reshape_rototranslation_nonseparable_exp(U{3}.signal{j2});
        end
    end    
    L2 = size(U{3}.signal{1},4);
    
    % Translation only there is no theta
    if strcmpi(scat_type,'t')
        U{3}.meta.resolution_theta = zeros(1,J2);
    end
    
    % Compute expected scattering for 2nd layer
    for j2=1:J2
        for j1=1:size(U{3}.signal{j2},5)
            for l2=1:L2
                EU{3}.signal = cat(2,EU{3}.signal,zeros(num_sig,1));
                for i=1:num_sig
                    sig = U{3}.signal{j2}(:,:,:,l2,j1,i);
                    avg = (2^(-p*U{3}.meta.resolution(j2)))*(2^(-p*U{3}.meta.resolution_theta(j2)/2))*mean(sig(:).^p);
                    EU{3}.signal(i,end) = avg;
                end
                EU{3}.meta.j = cat(2,EU{3}.meta.j,[U{2}.meta.j(j1);U{3}.meta.j(j2)]);
                EU{3}.meta.theta2_minus_theta1 = cat(2,EU{3}.meta.theta2_minus_theta1,l2-1);
                if ~strcmpi(scat_type,'t')
                    EU{3}.meta.k2 = cat(2,EU{3}.meta.k2,U{3}.meta.lambda_theta(j2));
                end
                EU{3}.meta.resolution_t = cat(2,EU{3}.meta.resolution_t,U{3}.meta.resolution(j2));
                EU{3}.meta.resolution_r = cat(2,EU{3}.meta.resolution_r,U{3}.meta.resolution_theta(j2));
            end
        end
    end
end

end