% RESHAPE_TRANSLATION_EXP
% Reshapes translation output U for expected scattering computation.
%
% Usage:
%   U2 = RESHAPE_TRANSLATION_EXP(U)
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

function U2 = reshape_translation_exp(U)

% Initialize
U2 = zeros(size(U));
L = size(U,3);

% Re-index so it is (theta1,theta2-theta1)
for theta1 = 1:L
    for theta2 = 1:L
        theta1_plus_theta2_modL = 1 + mod(theta1 + theta2 - 2, L);
        U2(:,:,theta1,theta2,:,:,:,:,:,:,:) = U(:,:,theta1,theta1_plus_theta2_modL,:,:,:,:,:,:,:);
    end
end

end