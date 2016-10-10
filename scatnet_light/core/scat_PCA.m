% SCAT Compute the scattering transform
%
% Usage
%    [S, S_tilde, U] = SCAT(x, Wop, PCA_filters, J) 
%
% Input
%    x (numeric): The input signal.
%    Wop (cell of function handles): Linear operators used to generate a new 
%       layer from the previous one.
%    PCA filters(cell with the filters learned up to the scale J)
%    J (single): the maximum scale used
%
% Output
%    S (numeric): The scattering PCA representation up to scale J
%    S_tilde (cell, optionnal): The scattering PCA representation up to the scale J+1
%    down sampled, ie S_\tilde_{j+1}
%    U (cell, optionnal): The U_{J+1} as written by Stéphane 
%
% Description
%    This function simply computes tilde_S, and if the two outputs are set
%    up, it computes S_tilde and U at the next scale!!!
%
% See also 
%   WAVELET_FACTORY_1D, WAVELET_FACTORY_2D, WAVELET_FACTORY_2D_PYRAMID

function [S, U] = scat_PCA(x, Wop,PCA_filters,J)
    % Initialize future cell
    % FUTURE: Faster initialization
    U=cell(1,length(Wop));
    S=cell(1,length(Wop));
    
	% Initialize signal and meta
	U{1}.signal{1} = x;
	U{1}.meta.j = zeros(0,1);
	U{1}.meta.q = zeros(0,1);
    U{1}.meta.resolution=0;

	% Apply scattering, order per order
	for j = 0:J-1
        if (m < numel(Wop)-1)
			[S{m+1}, V] = Wop{m+1}(U{m+1});
			U{m+2} = modulus_layer(V);
		else
			S{m+1} = Wop{m+1}(U{m+1});
        end
	end
end
