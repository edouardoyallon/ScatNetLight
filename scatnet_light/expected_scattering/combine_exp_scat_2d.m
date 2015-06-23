% COMBINE_EXP_SCAT_2D
% Combines two expected scattering representations (under certain assumptions)
%
% Usage:
%   [X, coeff_names, coeff_pars] = COMBINE_EXP_SCAT_2D(X1, X2, field_name, name1, name2, coeff_names1, coeff_pars1)
%
% Summary:
%   Combines two expected scattering representations computed over the same
%   data set, with the same scattering parameters, with the only difference
%   being a factor related to the data (indicated by field_name, name1, and
%   name2). For example, for the quantum chemistry data, the scattering
%   transform of the full electronic density versus only the density of the
%   valence electrons.
%
% Inputs:
%   1.) X1 (numeric): The unwound scattering coefficients of the first
%       scattering.
%   2.) X2 (numeric): The unwound scattering coefficients of the second
%       scattering. The size of X2 should be the same as the size of X1.
%   3.) field_name (string): The name of the data parameter that
%       distinguishes X1 from X2.
%   4.) name1 (string): The type of field_name for X1.
%   5.) name2 (string): The type of field_name for X2.
%   6.) coeff_names1 (cell): The scattering coefficient names of X1/X2, but
%       not distinguished by field_name.
%   7.) coeff_pars1 (struct): The scattering parameters of X1/X2, but not
%       distinguished by field_name.
%
% Outputs:
%   1.) X (numeric): Combination of X1 and X2; X = cat(2,X1,X2).
%   2.) coeff_names (cell): The coefficient names of X, distinguished by
%       field_name.
%   3.) coeff_pars (struct): The coefficient parameters of X, distinguished
%       by field_name.
%
% See also:
%   EXPECTED_SCAT_LIGHT_2D, UNWIND_EXP_SCAT_2D

function [X, coeff_names, coeff_pars] = combine_exp_scat_2d(X1, X2, field_name, name1, name2, coeff_names1, coeff_pars1)

% Combine X1 and X2
X = cat(2,X1,X2);

% Combine coefficient names
coeff_names2 = cell(size(coeff_names1));
for i=1:length(coeff_names1)
    coeff_names2{i} = strcat(coeff_names1{i},'_',name2);
    coeff_names1{i} = strcat(coeff_names1{i},'_',name1);
end
coeff_names = cat(2,coeff_names1,coeff_names2);

% Combine coefficient parameters
coeff_pars = struct;
coeff_pars.m = cat(2,coeff_pars1.m,coeff_pars1.m);
coeff_pars.j1 = cat(2,coeff_pars1.j1,coeff_pars1.j1);
coeff_pars.j2 = cat(2,coeff_pars1.j2,coeff_pars1.j2);
coeff_pars.theta2_minus_theta1 = cat(2,coeff_pars1.theta2_minus_theta1,coeff_pars1.theta2_minus_theta1);
coeff_pars.k2 = cat(2,coeff_pars1.k2,coeff_pars1.k2);
coeff_pars.moment = cat(2,coeff_pars1.moment,coeff_pars1.moment);
temp = cell(1,length(coeff_names));
for i=1:(length(temp)/2)
    temp{i} = name1;
    temp{i+(length(temp)/2)} = name2;
end
coeff_pars = setfield(coeff_pars,field_name,temp);

end