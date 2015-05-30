function U2=reshape_rototranslation_separable(U,dtheta1)

U2=zeros(size(U));
L1=size(U,3);
L2=size(U,4);
   for theta1=1:L1
                   for theta2=1:L2
                       theta1_plus_theta2=mod(theta1*2^dtheta1+theta2-1,L2)+1;
                       theta1_minus_theta2=mod(theta1*2^dtheta1-theta2-1,L2)+1;
                       U2(:,:,theta1_plus_theta2,theta1_minus_theta2,:,:,:,:,:,:,:)=U(:,:,theta1,theta2,:,:,:,:,:,:,:);
                   end
   end
end