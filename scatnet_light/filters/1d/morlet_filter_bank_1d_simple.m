% MORLET_FILTER_BANK_1D_SIMPLE
% Compute a bank of 1D Morlet wavelet filters in the Fourier domain
%
% Usage:
%   filters = MORLET_FILTER_BANK_1D_SIMPLE(N, options)
%
% Inputs:
%   1.) N (integer): Positive integer indicating the length of the signal
%       on which to apply the wavelet transform.
%   2.) options (struct): Options of the filters. Possible fields are:
%       a.) J (integer): The number of octaves.
%       b.) n_wavelet_per_octave (integer): The number of wavelet scales
%           per octave.
%       c.) sigma_phi (numeric): Standard deviation (width) of the low pass
%           mother filter.
%       d.) sigma_psi (numeric): Standard deviation (width) of the envelope
%           of the band pass mother wavelet.
%       e.) xi_psi (numeric): The frequency peak of the band pass mother
%           wavelet.
%       f.) min_margin (numeric): The minimum margin for padding the
%           initial size in for the filters.
%
% Outputs:
%   1.) filters (struct): The filters, with the following fields:
%       a.) phi (struct): Low pass filter phi.
%       b.) psi (struct):  Band pass filter psi.
%       c.) meta (struct): Contains meta information for the filters.
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% Email: mhirn@msu.edu

function filters = morlet_filter_bank_1d_simple(N, options)

% Optional inputs
if nargin < 2
    options = struct;
end

% Fill options as needed
options = fill_struct(options, 'J', floor(log2(N)));
options = fill_struct(options, 'n_wavelet_per_octave', 1);
J = options.J;
Q = options.n_wavelet_per_octave;
options = fill_struct(options, 'sigma_phi', 0.8);
options = fill_struct(options, 'sigma_psi', 0.8);
options = fill_struct(options, 'xi_psi',  1/2*(2^(-1/Q)+1)*pi);
options = fill_struct(options, 'filter_format', 'fourier_multires');
options = fill_struct(options, 'min_margin', options.sigma_phi * (2^J));
sigma_phi  = options.sigma_phi;
sigma_psi  = options.sigma_psi;
xi_psi     = options.xi_psi;

% Size of the filter at the highest resolution
size_filter = pad_size(N, options.min_margin, J);

% Compute low pass filter phi at all resolutions (fourier_multires)
scale = 2^(J-1);
filter_spatial = gaussian_1d(size_filter, sigma_phi*scale);
filter_spatial = fftshift(filter_spatial);
phi.filter = single(real(fft(filter_spatial)));
phi.filter = periodize_filter_3d(phi.filter);
phi.meta.J = J;

end