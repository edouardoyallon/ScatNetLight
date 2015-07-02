% LITTLEWOOD_PALEY Calculate Littlewood-Paley sum of a filter bank
%
% Usage
%    A = littlewood_paley(filters, N);
%
% Input
%    filters (struct): filter bank (see FILTER_BANK)
%    N (vector, optional): the signal size at which the sum should be 
%        calculated
%
% Description
%    The function computes the Littlewood-Paley sum of the filter bank at the
%    signal size N, which needs to be of the form filters.meta.size_filter*2^(-j0), where 
%    filters.N is the size for which the filters are defined.
%
% See also
%    PLOT_LITTLEWOOD_PALEY_1D, DISPLAY_LITTLEWOOD_PALEY_2D, FILTER_BANK

function energy = littlewood_paley(filters,N)

% Optional input
if nargin < 2
    N = [];
end

% Max filter size if no inputted N
if isempty(N) && isfield(filters,'meta') && isfield(filters.meta,'size_filter')
    N = filters.meta.size_filter;
else
    error('Unable to find max filter size!');
end

% For 1D
if length(N) == 1
    N = [N 1];
end

% Add up energies of the wavelets
energy = zeros(N);
for p = 1:length(filters.psi.filter)
    if length(N) < 3
        filter_coefft = realize_filter(filters.psi.filter{p},N);
    else
        filter_coefft = filters.psi.filter{p}.coefft{1};
    end
    energy = energy + abs(filter_coefft.^2);
end

% If 1D or 2D, get energy in negative frequencies 
if length(N) < 3
    energy = 0.5*(energy + circshift(rot90(energy,2), [1, 1]));
end

% Low pass energy
if length(N) < 3
    filter_coefft = realize_filter(filters.phi.filter,N);
else
    filter_coefft = filters.phi.filter.coefft{1};
end
energy = energy + abs(filter_coefft.^2);

end