% FILTERS_FACTORY_1D
% Creates 1D wavelet filters only. Does not create the function handle of
% the wavelet operator.
%
% Usage:
%   filters = FILTERS_FACTORY_1D(N, filt_opt)
%
% Inputs:
%   1.) N (integer): Positive integer indicating the length of the signal
%       on which to apply the wavelet transform.
%   2.) filt_opt (struct): Struct containing the field 'filter_type', which
%       specifies the type of wavelet. At the moment the only option is
%       'morlet' for Morlet wavelets. Additional filter options are set
%       according to the wavelet type; see MORLET_FILTER_BANK_1D_SIMPLE.
%
% Outputs:
%   1.) filters (struct): Contains the filters and meta information. See
%       MORLET_FILTER_BANK_1D_SIMPLE for more information.
%
% See also:
%   WAVELET_OPERATOR_1D
%
% This file is part of ScatNetLight
% Author: Matthew Hirn
% email: mhirn@msu.edu

function filters = filters_factory_1d(N, filt_opt)

% Optional inputs
if nargin < 2
    filt_opt = struct;
end

% Default wavelet type is Morlet
filt_opt = fill_struct(filt_opt, 'filter_type', 'morlet');

switch lower(filt_opt.filter_type)
    case 'morlet'
        filters = morlet_filter_bank_1d_simple(N, filt_opt);
    otherwise
        error('Unsupported filter type.');
end

end