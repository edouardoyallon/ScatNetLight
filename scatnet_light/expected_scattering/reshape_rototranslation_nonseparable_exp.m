% RESHAPE_ROTOTRANSLATION_NONSEPARABLE_EXP
% Reshapes nonseparable roto-translation output U for expected scattering
%   computation.
%
% Usage:
%   U2 = RESHAPE_ROTOTRANSLATION_NONSEPARABLE_EXP(U)
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

function U2 = reshape_rototranslation_nonseparable_exp(U)

% Move "negative scales" to be theta2-theta1 angles from [pi,2pi)
U2 = cat(4, U(:,:,:,:,:,1,:,:,:,:,:), U(:,:,:,:,:,2,:,:,:,:,:));

end