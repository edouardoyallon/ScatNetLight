function U2 = reshape_rototranslation_separable_exp(U)

% First move "negative scales" to be theta2 angles from [pi,2pi)
U = cat(4, U(:,:,:,:,:,1,:,:,:,:,:), U(:,:,:,:,:,2,:,:,:,:,:));

% Copy theta1 angles from [0,pi) to [pi,2pi)
U = cat(3, U, U);

% Initialize
L = size(U,4);
U2 = zeros(size(U));

% Re-index so it is (theta1,theta2-theta1)
for theta1 = 1:L
    for theta2 = 1:L
        theta1_plus_theta2_modL = 1 + mod(theta1 + theta2 - 2, L);
        U2(:,:,theta1,theta2,:,:,:,:,:,:,:) = U(:,:,theta1,theta1_plus_theta2_modL,:,:,:,:,:,:,:);
    end
end

end