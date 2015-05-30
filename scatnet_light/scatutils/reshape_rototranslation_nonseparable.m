function U2=reshape_rototranslation_nonseparable(U)


s=size(U);
L=s(3);
s(3)=2*L;

U2=zeros(s);

   for theta2=1:L
                   for theta=1:2*L
                       theta_modL=1+ mod(theta-1,L);
                       theta2_plus_theta_modL =  1 + mod(theta + theta2 - 2, L);
                       theta2_plus_theta_mod2L =  1 + mod(theta + theta2 - 2, 2*L);
                       if(theta2_plus_theta_mod2L<9)
                      U2(:,:,theta,theta2,:,:,:,:,:,:,:)=U(:,:,theta_modL,theta2_plus_theta_modL,:,:,:,:,:,:,:);
                       else
                       U2(:,:,theta,theta2,:,:,:,:,:,:,:)=conj(U(:,:,theta_modL,theta2_plus_theta_modL,:,:,:,:,:,:,:));
                       end
                   end
   end



end