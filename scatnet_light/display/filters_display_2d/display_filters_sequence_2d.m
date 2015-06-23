% DISPLAY_FILTERS_SEQUENCE_2D
% Displays the filters one after the other, in sequence
%
% Usage:
%   DISPLAY_FILTERS_SEQUENCE_2D(filters)
%   DISPLAY_FILTERS_SEQUENCE_2D(filters,m)
%   DISPLAY_FILTERS_SEQUENCE_2D(filters,m,n)
%
% Inputs:
%   filters (cell): The filters, as outputted by WAVELET_FACTORY_2D
%   m (integer): Display the filters for scattering layer m [default: m=1]
%   n (integer): Pause between filters for n seconds. If not inputted, the
%       user must hit a key to continue to the next filter.

function display_filters_sequence_2d(filters,m,n)

% Optional inputs
if nargin < 2
    m = 1;
end
if nargin < 3
    n = Inf;
end

% Loop through wavelets
for k=1:length(filters{m}.translation.psi.filter)
    
    % Wavelet in space
    x=ifftshift(ifft2(filters{m}.translation.psi.filter{k}.coefft{1}));
    
    % Display real part
    subplot(2,2,1);imagesc(real(x));axis('image');
    title('Real part');
    
    % Display imaginary part
    subplot(2,2,3);imagesc(imag(x));axis('image');
    title('Imaginary part');
    
    % Display in frequency
    subplot(2,2,[2 4]);imagesc(fftshift(filters{m}.translation.psi.filter{k}.coefft{1}));axis('image');
    title('Fourier transform');
    
    % Pause
    if n < Inf
        pause(n);
    else
        pause;
    end
    
end

end