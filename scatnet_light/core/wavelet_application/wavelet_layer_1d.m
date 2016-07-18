% WAVELET_LAYER_1D
% Compute the wavelet transform of any scattering layer in 1D
%
% Usage:
%   [U_phi, U_psi] = WAVELET_LAYER_1D(U, filters, options)
%
% Inputs:
%   1.) U (struct): Previous scattering layer
%   2.) filters (struct): Filter bank
%   3.) options (struct): Options for the wavelet transform, as in
%       WAVELET_1D
%
% Output:
%   1.) U_phi (struct): Average (low pass) of wavelet coefficients
%   2.) U_psi (struct): Wavelet coefficients of next layer
%
% Description
%   This function has a pivotal role between WAVELET_1D (which computes a
%   single wavelet transform), and WAVELET_OPERATOR_1D (which creates the
%   whole cascade). Given an input corresponding to the initial signal,
%   WAVELET_LAYER_1D computes the wavelet transform coefficients of the 
%   next layer using WAVELET_1D.
%
% See also
%   WAVELET_1D, WAVELET_OPERATOR_3D
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: mhirn@msu.edu

function [U_phi, U_psi] = wavelet_layer_1d(U, filters, options)














end