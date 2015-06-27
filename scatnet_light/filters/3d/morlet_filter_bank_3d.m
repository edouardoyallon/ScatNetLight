% MORLET_FILTER_BANK_3D
% Compute a bank of 3D Morlet wavelet filters in the Fourier domain.
%
% Usage:
%   filters = MORLET_FILTER_BANK_3D(size_in,options)
%
% Inputs:
%   1.) size_in (numeric): 1x3 vector [N1,N2,N3] indicating the size of the
%       3D signal on which to apply the wavelet transform.
%   2.) options (structure): Options of the bank of filters. Optional, with
%       fields:
%       a.) J (numeric): The number of octaves. 
%       b.) n_wavelet_per_octave (numeric): Number of wavelet scales per
%           octave.
%       c.) n_subdivision_sphere (numeric): The number of subdivisions of
%           the sphere based on starting with a regular octahedron. The 
%           vertices sample the sphere, which in turn are used as a 
%           sampling of the set of 3D rotations.
%       d.) antipodal (logical): If true, keeps antipodal points on the
%           subdivision of the sphere, which is redundant for real valued
%           signals. If false, antipodal points are removed.
%       e.) sigma_phi (numeric): Standard deviation (width) of the low pass
%           mother wavelet.
%       f.) sigma_psi (numeric): Standard deviation (width) of the envelope
%           of the band pass mother wavelet.
%       g.) xi_psi (numeric): The frequency peak of the band pass mother
%           wavelet is (0,0.xi_psi).
%       h.) slant_psi (numeic): The eccentricity of the elliptic envelope
%           of the band pass wavelet (along the z-axis).
%       i.) filter_format (string): How to store the filters. Must be
%           'fourier_multires' right now.
%       j.) min_margin (numeric): The minimum margin for padding the
%           initial size in for the filters.
%
% Outputs:
%   1.) filters (structure): The filters, with the following fields:
%       a.) phi (structure): Low pass filter phi.
%       b.) psi (structure):  Band pass filter psi.
%       c.) meta (structure): Contains meta information for the filters.
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

function filters = morlet_filter_bank_3d(size_in, options)

% Preprocessing
if nargin < 2
    options = struct;
end

% Options
options = fill_struct(options, 'J', 4);
options = fill_struct(options, 'n_wavelet_per_octave', 1);
J = options.J;
Q = options.n_wavelet_per_octave;
options = fill_struct(options, 'base_mesh', 'oct');
options = fill_struct(options, 'n_subdivision_sphere', 3);
options = fill_struct(options, 'antipodal', false);
options = fill_struct(options, 'sigma_phi', 0.8);
options = fill_struct(options, 'sigma_psi', 0.8);
options = fill_struct(options, 'xi_psi',  1/2*(2^(-1/Q)+1)*pi);
options = fill_struct(options, 'slant_psi',  2/3);
options = fill_struct(options, 'filter_format', 'fourier_multires');
options = fill_struct(options, 'min_margin', options.sigma_phi * (2^J));
sigma_phi  = options.sigma_phi;
sigma_psi  = options.sigma_psi;
xi_psi     = options.xi_psi;
slant_psi  = options.slant_psi;

% Size of the filter at the highest resolution
size_filter = pad_size(size_in, options.min_margin, J);

% Compute low pass filter phi at all resolutions (fourier_multires)
scale = 2^(J-1);
filter_spatial = gaussian_3d(size_filter,sigma_phi*scale);
filter_spatial = fftshift(filter_spatial);
phi.filter = single(real(fftn(filter_spatial)));
phi.filter = periodize_filter_3d(phi.filter);
phi.meta.J = J;

% Angles are drawn from SO(3)=S^2xSO(2), but we only need to sample S^2
% since the base Morlet wavelet is radially symmetric about (0,0,xi_psi).
options_angle.base_mesh = options.base_mesh;
angle_axes = compute_semiregular_sphere(options.n_subdivision_sphere,options_angle);

% Remove antipodal points 
if ~options.antipodal
    angle_axes = angle_axes';
    c = 1;
    while c < size(angle_axes,1);    
        axis0 = angle_axes(c,:);
        i = ismember(angle_axes,-axis0,'rows');
        angle_axes(i,:) = [];
        c = c+1;
    end
    angle_axes = angle_axes';
end
num_angles = size(angle_axes,2);

% Compute the wavelet filters psi
psi.filter = cell(1,J*Q*num_angles);
psi.meta.j = zeros(1,J*Q*num_angles);
psi.meta.axis = zeros(3,J*Q*num_angles);
littlewood_paley = zeros(size_filter);
p = 1;
for j=0:(J-1)
    for q=0:(Q-1)
        for a = 1:num_angles
            scale = 2^(j+q/Q);
            angle_axis = angle_axes(:,a);
            filter_spatial = morlet_3d(size_filter,sigma_psi*scale,...
                slant_psi,xi_psi/scale,angle_axis');
            filter_spatial = fftshift(filter_spatial);
            
            psi.filter{p} = single(real(fft3(filter_spatial)));
            psi.meta.j(p) = j + q/Q;
            psi.meta.axis(:,p) = angle_axis;
            
            littlewood_paley = littlewood_paley + abs(psi.filter{p}).^2;
            
            p = p + 1;
        end
    end
end

% Renormalize psi by max of Littlewood Paley to have an almost unitary
% operator.
K = max(littlewood_paley(:));
for p=1:(J*Q*num_angles)
    psi.filter{p} = psi.filter{p}/sqrt(K/2);
    psi.filter{p} = periodize_filter_3d(psi.filter{p});
end

% Format output
filters.phi = phi;
filters.psi = psi;
filters.meta.wavelet = 'Morlet';
filters.meta.J = J;
filters.meta.n_wavelet_per_octave = Q;
filters.meta.base_mesh = options.base_mesh;
filters.meta.n_subdivision_sphere = options.n_subdivision_sphere;
filters.meta.antipodal = options.antipodal;
filters.meta.L = num_angles;
filters.meta.sigma_phi = sigma_phi;
filters.meta.sigma_psi = sigma_psi;
filters.meta.xi_psi = xi_psi;
filters.meta.slant_psi = slant_psi;
filters.meta.size_in = size_in;
filters.meta.size_filter = size_filter;

end