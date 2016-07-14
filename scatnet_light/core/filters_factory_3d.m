% FILTERS_FACTORY_3D
% Creates 3D wavelet filters only. Does not create the function handle of
% the wavelet operator.
%
% Usage:
%   filters = FILTERS_FACTORY_3D(size_in, filt_opt)
%
% Inputs:
%   1.) size_in (numeric): 1x3 vector [N1,N2,N3] indicating the size of the
%       3D signal on which to apply the wavelet transform.
%   2.) filt_opt (struct): A struct with the sole field 'translation', to
%       indicate the wavelet filters constructed are over the translation
%       group (eventually 'rotation' will be implemented for wavelet
%       transforms over the 3D rotation group). The field translation is
%       itself a struct, containig the field 'filter_type', which must be
%       set to 'morlet', indicating that the fitlers are Morlet wavelets
%       (other wavelets may be implemented in the future). Other filter
%       options can be set within the translation field, see 
%       MORLET_FILTER_BANK_3D.
%
% Outputs:
%   1.) filters (structure): Contains the filters and meta information. See
%       MORLET_FILTER_BANK_3D for more information.
%
% See also:
%   WAVELET_OPERATOR_3D
%
% This file is part of ScatNetLight.
% Authors: Matthew Hirn and Guy Wolf
% email: matthew.hirn@ens.fr, guy.wolf@ens.fr

function filters = filters_factory_3d(size_in, filt_opt)

% Optional inputs
if nargin < 2
    filt_opt = struct;
end

% Default (and only) wavelet type is Morlet
filt_opt = fill_struct(filt_opt, 'translation', []);
filt_opt.translation = fill_struct(filt_opt.translation, 'filter_type', 'morlet');

% Build the filters (which are assumed to be the same at each layer)
switch lower(filt_opt.translation.filter_type)
    case 'morlet'
        filters.translation = morlet_filter_bank_3d(size_in, filt_opt.translation);
    otherwise
        error('Unsupported filter type.');
end

end