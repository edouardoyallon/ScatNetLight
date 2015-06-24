% WAVELET_FACTORY_3D
% Create 3D wavelet cascade.
%
% Usage:
%   [Wop, filters] = WAVELET_FACTORY_3D(size_in, filt_opt, scat_opt)
%
% Inputs:
%   1.) size_in (numeric): 1x3 vector [N1,N2,N3] indicating the size of the
%       3D signal on which to apply the wavelet transform.
%   2.) filt_opt (structure): Specifies the filter options, within the
%       field 'layer', which is a cell of size 1x(M+1), where M is the
%       number of scattering layers. For each layer m=0,...M, layer{m+1}
%       is a structure with the following fields:
%       a.) translation (structure): Specifies the options of the wavelet
%           transform over rotations in R^3. Contains the field 
%           'filter_type', which specifies the type of wavelet (must be set
%           to 'morlet'). See MORLET_FILTER_BANK_3D.
%       b.) rotation (structure): Specifies the options of the wavelet
%           transform over rotations. CURRENTLY NOT IMPLEMENTED.
%   3.) scat_opt (structure): Specifies the scattering options, within the
%       fields:
%       a.) M (numeric): The number of scattering layers.
%       b.) layer (cell): A cell of size 1x(M+1), where for each layer
%           m=0,...,M, layer{m+1} is a structure with the fields
%           'translation' and 'rotation'. These fields are themselves
%           structures, which both contain the following field:
%           i.)  oversampling (numeric): Oversampling factory. Can be set 
%                to Inf, in which no subsampling occurs.
%           For translation and for layers m>0, the following field should
%           also be set:
%           ii.) type (string): Determines the type of scattering
%               transform, either translation ('t'), roto-translation
%               separable ('tr'), or roto-translation nonseparable
%               ('tr_nonsepa').
%           For rotations and for layers m>0, the following field should
%           also be set:
%           ii.) output_averaging (logical): If true, outputs the averaging
%               along angles in the S.
%
% Outputs:
%   1.) Wop (function handle): The function handles for the cascade of
%       wavelet transforms.
%   2.) filters (structure): Contains the filters and meta information. See
%       MORLET_FILTER_BANK_3D for more information.
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

function [Wop, filters] = wavelet_factory_3d(size_in, filt_opt, scat_opt)

% Initialize
if nargin < 3
    scat_opt = struct;
end
if nargin < 2
    filt_opt = struct;
end

% Scattering options
scat_opt = fill_struct(scat_opt, 'M', 2);
scat_opt = fill_struct(scat_opt, 'type', 't');

% Build the operator for each layer
Wop = cell(1,scat_opt.M+1);
filters = cell(1,scat_opt.M+1);
for m = 1:scat_opt.M+1
    
    % Create filters for translation
    filt_opt.layer{m}.translation = fill_struct(...
        filt_opt.layer{m}.translation, 'filter_type', 'morlet');
    switch lower(filt_opt.layer{m}.translation.filter_type)
        case 'morlet'
            filters{m}.translation = morlet_filter_bank_3d(...
                size_in, filt_opt.layer{m}.translation);
        otherwise
            error('Unsupported filter type');
    end
    
    % Create the wavelet transform to apply at the m-th layer
    if m==1 || (m==2 && scat_opt.M==1)
        Wop{m} = @(x)(wavelet_layer_1_3d(...
            x, filters{m}.translation, scat_opt.layer{m}.translation));
    else
        switch lower(scat_opt.type)
            case 't'
                Wop{m} = @(x)(wavelet_layer_2_3d(x, ...
                    filters{m}.translation, scat_opt.layer{m}.translation));
            otherwise
                error('Unsupported scattering type');
        end
    end    
    
end

end