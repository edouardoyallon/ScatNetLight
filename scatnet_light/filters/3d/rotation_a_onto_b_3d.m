% ROTATION_A_ONTO_B_3D
% Computes the 3D rotation taking the vector a onto the vector b.
%
% Usage:
%   R = ROTATION_A_ONTO_B_3D(A,B)
%
% Inputs:
%   1.) a (numeric): A 1x3 vector
%   2.) b (numeric): A 1x3 vector
%
% Outputs:
%   1.) R (numeric): The 3x3 rotation matrix taking a onto b.
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr

function R = rotation_a_onto_b_3d(a,b)

% Normalize
a = a/norm(a);
b = b/norm(b);

% --- Three cases ---

% a = b
if a==b
    R = eye(3);

% a = -b    
elseif a==-b
    temp = null(a);
    v = temp(:,1);
    vx = [0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0];
    c = dot(a,b);
    R = eye(3) + (1-c) * vx^2;
    
% Everything else    
else    
    v = cross(a,b);
    s = norm(v);
    c = dot(a,b);
    vx = [0 -v(3) v(2); v(3) 0 -v(1); -v(2) v(1) 0];
    R = eye(3) + vx + ((1-c)/s^2) * vx^2;
    
end

end