% WAVELET_OPERATOR_1D
% Creates the function handle of the 1D wavelet operator only. Does not
% create the wavelet filters, they must be inputted.
%
% Usage:
%   [Wop, scat_opt_out] = WAVELET_OPERATOR_1D(filters, scat_opt_in)
%
% Inputs:
%   1.) filters (struct): The wavelet filters, as outputted by 
%       FILTERS_FACTORY_1D.
%   2.) scat_opt_in (struct): The scattering options, with the following
%       fields:
%       a.) M (integer): The number of scattering layers.
%       b.) boundary (string): The type of boundary condition (i.e., the 
%           way the signal is padded). Can be either 'zero', 'symm', or 
%           'per'.
%       c.) oversampling (integer): The signals by default are downsampled
%           at the critical sampling rate. This will increase the sampling
%           rate by a factor of 2^oversampling.
%       d.) compute_low_pass (boolean): If true, after each propogation
%           layer U (wavelet modulus operator), a low pass filter is 
%           applied giving a translation invariant scattering
%           representation up to the specified scale. If false, no low pass
%           filter is applied and only the propogator coefficients (i.e., 
%           the cascaded wavelet modulus operator) at each layer are 
%           returned. 
%
% Outputs:
%   1.) Wop (struct): Struct consisting of two fields:
%       a.) 
%   
%
% See also:
%   FILTERS_FACTORY_1D, SCAT
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: mhirn@msu.edu

function [Wop, scat_opt_out] = wavelet_operator_1d(filters, scat_opt_in)

% Optional inputs
if nargin < 2
    scat_opt_out = struct;
else
    scat_opt_out = scat_opt_in;
end

% Scattering options
scat_opt_out = fill_struct(scat_opt_out, 'M', 2);
scat_opt_out = fill_struct(scat_opt_out, 'boundary', 'zero');
scat_opt_out = fill_struct(scat_opt_out, 'oversampling', 0);
scat_opt_out = fill_struct(scat_opt_out, 'compute_low_pass', true);

% The Wop is the same each layer, so we just save it once
Wop.function_handle = @(x)(wavelet_layer_1d(x, filters, scat_opt_out));
Wop.num_layers = scat_opt_out.M;

end