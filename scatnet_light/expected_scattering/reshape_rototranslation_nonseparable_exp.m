function U2 = reshape_rototranslation_nonseparable_exp(U)

% Move "negative scales" to be theta2-theta1 angles from [pi,2pi)
U2 = cat(4, U(:,:,:,:,:,1,:,:,:,:,:), U(:,:,:,:,:,2,:,:,:,:,:));

end