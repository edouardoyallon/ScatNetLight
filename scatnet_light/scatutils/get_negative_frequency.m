function x=get_negative_frequency(x)
% The negative frequency are put after u1,u2,theta1,theta2,j1 so at the 6th
% position
    x=format_orbit({x,conj(x)},{1:2},6);
    x=x{1};
end