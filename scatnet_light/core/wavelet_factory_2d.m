% WAVELET_FACTORY_2D Create wavelet cascade from morlet filter bank
%
% Usage
%    [Wop, filters] = WAVELET_FACTORY_2D(size_in, filt_opt, scat_opt)
%
% Input
%    size_in (numeric): The size of the signals to be transformed.
%    filt_opt (structure): The filter options, same as for
%       MORLET_FILTER_BANK_2D, HAAR_FILTER_BANK_2D or SHANNON_FILTER_BANK_2D
%	 scat_opt (structure): The scattering and wavelet options, identical to
%       WAVELET_LAYER_1D/WAVELET_1D.
%
% Output
%    Wop (cell of function handle): A cell array of wavelet transforms
%    required for the scattering transform.
%    filters (cell): A cell array of the filters used in defining the wavelets.

% Note
%    If M, the number of layer, is not specified, its value is set automatically to 2.
%
% See also
%    WAVELET_2D, MORLET_FILTER_BANK_2D, SHANNON_FILTER_BANK_2D

function [Wop, filters] = wavelet_factory_2d(size_in, filt_opt, scat_opt)

if(nargin<3)
    scat_opt=struct;
end

if(nargin<2)
    filt_opt=struct;
end

% Detail the number of layers accepted
scat_opt = fill_struct(scat_opt, 'M', 2);

% Future operator
Wop=cell(scat_opt.M+1,1);

% Build the operator for each layer
filters = cell(1,scat_opt.M+1);
for m = 1:scat_opt.M+1
    % Check options
    white_list_scat_layer_translation = { 'oversampling','M','type','padding'};
    check_options_white_list(scat_opt.layer{m}.translation, white_list_scat_layer_translation);
    
    % Create filters for translation
    filt_opt.layer{m}.translation = fill_struct(filt_opt.layer{m}.translation, 'filter_type', 'morlet');
    
    switch filt_opt.layer{m}.translation.filter_type
        case 'morlet'
            filt_opt.layer{m}.translation = rmfield(filt_opt.layer{m}.translation, 'filter_type');
            filters{m}.translation = morlet_filter_bank_2d(size_in, filt_opt.layer{m}.translation);
        case 'shannon'
            filt_opt.layer{m}.translation = rmfield(filt_opt.layer{m}.translation, 'filter_type');
            filters{m}.translation = shannon_filter_bank_2d(size_in, filt_opt.layer{m}.translation);
        case 'haar'
            filt_opt.layer{m}.translation = rmfield(filt_opt.layer{m}.translation, 'filter_type');
            filters{m}.translation = haar_filter_bank_2d(size_in, filt_opt.layer{m}.translation);
        otherwise
            error('unsupported filter type');
    end
    
    % Create filters for rotation
    if(m>1 && (strcmp(scat_opt.layer{m}.translation.type,'tr')  || strcmp(scat_opt.layer{m}.translation.type,'tr_nonsepa')))
        filt_opt.layer{m}.rotation = fill_struct(filt_opt.layer{m}.rotation, 'filter_type', 'morlet_1d');
        sz = filt_opt.layer{m-1}.translation.L ;
        
        % Should we output the averaging?
        scat_opt.layer{m}.rotation = fill_struct(scat_opt.layer{m}.rotation, 'output_averaging', 0);
        
        % If non separable, then we have twice the number of orientation at
        % U2...
        if(strcmp(scat_opt.layer{m}.translation.type,'tr_nonsepa'))
            sz=sz*2;
        end
        
        switch filt_opt.layer{m}.rotation.filter_type
            case 'morlet_1d'
                filters{m}.rotation = morlet_filter_bank_1d(sz, filt_opt.layer{m}.rotation);
            case 'meyer_1d'
                filters{m}.rotation = meyer_filter_bank_1d(sz, filt_opt.layer{m}.rotation);
            otherwise
                error('unsupported filter type');
        end
        options_W_rotation = scat_opt.layer{m}.rotation;
    end
    
    options_W_translation = scat_opt.layer{m}.translation;
    
    % Create the wavelet transform to apply at the m-th layer
    if(m==1)
        Wop{m} = @(x)(wavelet_layer_1_2d(x, filters{m}.translation, options_W_translation));
    elseif(m==2)
        switch scat_opt.layer{m}.translation.type
            case 't'
                Wop{m} = @(x)(wavelet_layer_2_2d(x, filters{m}.translation, options_W_translation));
            case {'tr','tr_nonsepa'}
                Wop{m} = @(x)(wavelet_layer_2_rototrans(x, filters{m}.translation, filters{m}.rotation, options_W_translation, options_W_rotation));
            otherwise
                error('type not found');
        end
    elseif(m==3)
        switch scat_opt.layer{m}.translation.type
            case 't'
                Wop{m} = @(x)(wavelet_layer_2_2d(x, filters{m}.translation, options_W_translation));
            case {'tr','tr_nonsepa'}
                Wop{m} = @(x)(wavelet_layer_3_rototrans(x, filters{m}.translation, filters{m}.rotation, options_W_translation, options_W_rotation));
            otherwise
                error('type not found');
        end
    end
end
end

