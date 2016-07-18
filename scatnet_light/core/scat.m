% SCAT Compute the scattering transform
%
% Usage
%    [S, U] = SCAT(x, Wop) 
%
% Input
%    x (numeric): The input signal.
%    Wop (cell of function handles OR struct): Linear operators used to 
%       generate a new layer from the previous one. Wop can take two
%       formats:
%       a.) cell: Each Wop{m} propogates layer m-1 to layer m.
%       b.) struct: Wop has two fields:
%           i.)  Wop.function_handle: Propogates all layers.
%           ii.) Wop.num_layers: The number of layers to propogate.
%
% Output
%    S (cell): The scattering representation of x.
%    U (cell): Intermediate covariant modulus coefficients of x.
%
% Description
%    The signal x is decomposed using linear operators Wop and modulus 
%    operators, creating scattering invariants S and intermediate covariant
%    coefficients U. 
%
%    Each element of the Wop array is a function handle of the signature
%       [A, V] = Wop{m+1}(U)   OR    [A, V] = Wop.function_handle(U)
%    where m ranges from 0 to M (M being the order of the transform). The 
%    outputs A and V are the invariant and covariant parts of the operator.
%
%    The variables A, V and U are all of the same structure, that of a network
%    layer. Specifically, the have one field, signal, which is a cell array
%    corresponding to the constituent signals, and another field, meta, which
%    contains various information on these signals.
%
%    The scattering transform therefore initializes the first layer of U using
%    the input signal x, then iterates on the following transformation
%       [S{m+1}, V] = Wop{m+1}(U{m+1});
%       U{m+2} = modulus_layer(V);
%    or alternatively:
%       [S{m+1}, V] = Wop.function_handle(U{m+1});
%       U{m+2} = modulus_layer(V);
%    The invariant part of the linear operator is therefore output as a scat-
%    tering coefficient, and the modulus covariant part V is assigned to the 
%    next layer of U.
%
% See also 
%   WAVELET_FACTORY_1D, WAVELET_FACTORY_2D, WAVELET_FACTORY_2D_PYRAMID

function [S, U] = scat(x, Wop)
    
    % Initialize future cell
    if iscell(Wop)
        U = cell(1, length(Wop));
        S = cell(1, length(Wop));
        M = length(Wop) - 1;
    else
        U = cell(1, Wop.num_layers + 1);
        S = cell(1, Wop.num_layers + 1);
        M = Wop.num_layers;
    end
    
	% Initialize signal and meta
	U{1}.signal{1} = x;
	U{1}.meta.j = zeros(0,1);
	U{1}.meta.q = zeros(0,1);
    U{1}.meta.resolution=0;

	% Apply scattering, order per order
	for m = 0:M
        if (m < M)
            if iscell(Wop)
                [S{m+1}, V] = Wop{m+1}(U{m+1});
            else
                [S{m+1}, V] = Wop.function_handle(U{m+1});
            end
			U{m+2} = modulus_layer(V);
        else
            if iscell(Wop)
                S{m+1} = Wop{m+1}(U{m+1});
            else
                S{m+1} = Wop.function_handle(U{m+1});
            end
        end
	end
end
