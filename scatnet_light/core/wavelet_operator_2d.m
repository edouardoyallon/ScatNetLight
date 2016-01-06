% WAVELET_OPERATOR_2D
% Creates the function handle of the 2D wavelet operator only. Does not
% create the wavelet filters, they must be inputted.
%
% Usage:
%   Wop = WAVELET_OPERATOR_2D(filters, scat_opt_in)
%   [Wop, scat_opt_out] = WAVELET_OPERATOR_2D(filters, scat_opt_in)
%
% Inputs:
%   1.) filters (struct): The wavelet filters, as outputted by 
%       FILTERS_FACTORY_2D.
%   2.) scat_opt_in (struct): The scattering options, with the following
%       fields:
%       a.) M (integer): The number of scattering layers. Max is 2.
%       b.) type (string): The scattering type. Must be 't' for translation
%           (roto-translation is not implemented yet).
%       c.) translation (struct): Sub-struct containing options specific to
%           the translation part of the scattering transform. Fields within
%           translation are:
%           i.)  boundary (string): The type of boundary condition (i.e.,
%                the way the signal is padded). Can be either 'zero',
%                'symm', or 'per'.
%           ii.) oversampling (integer): The signals by default are
%               downsampled at the critical sampling rate. This will
%               increase the sampling rate by a factor of 2^oversampling.
%
% See also:
%   FILTERS_FACTORY_2D, SCAT
%
% This file is part of ScatNetLight.
% Authors: Matthew Hirn
% email: mhirn@msu.edu

function [Wop, scat_opt_out] = wavelet_operator_2d(filters, scat_opt_in)

% Optional inputs
if nargin < 2
    scat_opt_out = struct;
else
    scat_opt_out = scat_opt_in;
end

% Scattering options
scat_opt_out = fill_struct(scat_opt_out, 'M', 1);
scat_opt_out = fill_struct(scat_opt_out, 'type', 't');
scat_opt_out = fill_struct(scat_opt_out, 'translation', []);
scat_opt_out.translation = fill_struct(scat_opt_out.translation, 'padding', 'zero');
scat_opt_out.translation = fill_struct(scat_opt_out.translation, 'oversampling', 0);

% At the moment, I have only implemented translation scattering 
if ~strcmpi(scat_opt_out.type,'t')
    error('Unsupported scattering type.');
end

% Wavelet operators
switch scat_opt_out.M
    
    case 0
        Wop{1} = @(x)(wavelet_layer_1_2d(x, filters.translation, scat_opt_out.translation));
        
    case 1
        Wop{1} = @(x)(wavelet_layer_1_2d(x, filters.translation, scat_opt_out.translation));
        Wop{2} = @(x)(wavelet_layer_1_2d(x, filters.translation, scat_opt_out.translation));
        
    case 2
        Wop{1} = @(x)(wavelet_layer_1_2d(x, filters.translation, scat_opt_out.translation));
        Wop{2} = @(x)(wavelet_layer_2_2d(x, filters.translation, scat_opt_out.translation));
        Wop{3} = @(x)(wavelet_layer_2_2d(x, filters.translation, scat_opt_out.translation));
        
    otherwise
        error('2D scattering only supports up to 2 layers.');
        
end

end