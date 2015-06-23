% UNWIND_EXP_SCAT
% Unwinds the expected scattering coefficients to be used in regression 
%   tasks. Also returns the scattering names and parameters for the unwound
%   matrix.
%
% Usage:
%   [X, coeff_names, coeff_pars] = UNWIND_EXP_SCAT(EU1, scat_type)
%   [X, coeff_names, coeff_pars] = UNWIND_EXP_SCAT(EU1, EU2, scat_type)
%
% Inputs:
%   1.) EU1 (cell): L1 expected scattering output
%   2.) EU2 (cell): L2 expected scattering output
%
% Outputs:
%   1.) X (numeric): Matrix of scattering coefficients. Rows are data
%       points, columns are scattering features.
%   2.) coeff_names (cell): Contains strings with the names of each
%       scattering feature.
%   3.) coeff_pars (struct): Struct containing fields with different
%       scattering parameters, and their value for each scattering feature.

function [X, coeff_names, coeff_pars] = unwind_exp_scat(EU1, varargin)

% Variable inputs
if length(varargin) == 1
    scat_type = varargin{1};
else
    EU2 = varargin{1};
    scat_type = varargin{2};
end

% Unwind scat
X = [];
for m=1:length(EU1)    
    X = cat(2,X,EU1{m}.signal);
    if nargin > 2
        X = cat(2,X,EU2{m}.signal);
    end    
end

% Coefficient names
if nargout > 1
    
    % Pre-allocate
    coeff_names = cell(1,size(X,2));
    coeff_pars.m = zeros(1,size(X,2));
    coeff_pars.j1 = zeros(1,size(X,2));
    coeff_pars.j2 = zeros(1,size(X,2));
    coeff_pars.theta2_minus_theta1 = zeros(1,size(X,2));
    coeff_pars.k2 = zeros(1,size(X,2));
    coeff_pars.moment = zeros(1,size(X,2));  
    
    J = max(EU1{2}.meta.j) + 1;
    
    % Counter
    counter = 1;
    
    % Layer 0
    coeff_names{1} = 'L1^1_m=0';
    coeff_pars.m(1) = 0;
    coeff_pars.j1(1) = J;
    coeff_pars.j2(1) = J;
    coeff_pars.k2(1) = -1;
    coeff_pars.theta2_minus_theta1(1) = -1;
    coeff_pars.moment(1) = 1;
    counter = counter + 1;
    
    if nargin > 2
        coeff_names{2} = 'L2^2_m=0';
        coeff_pars.m(2) = 0;
        coeff_pars.j1(2) = J;
        coeff_pars.j2(2) = J;
        coeff_pars.k2(2) = -1;
        coeff_pars.theta2_minus_theta1(2) = -1;
        coeff_pars.moment(2) = 2;
        counter = counter + 1;
    end
    
    % Layer 1
    for i=1:length(EU1{2}.meta.j)
        coeff_names{counter} = strcat('L1^1_m=1_j1=',num2str(EU1{2}.meta.j(i)));
        coeff_pars.m(counter) = 1;
        coeff_pars.j1(counter) = EU1{2}.meta.j(i);
        coeff_pars.j2(counter) = J;
        coeff_pars.k2(counter)  = -1;
        coeff_pars.theta2_minus_theta1(counter) = -1;
        coeff_pars.moment(counter) = 1;
        counter = counter + 1;
        
        if nargin > 2
            coeff_names{counter} = strcat('L2^2_m=1_j1=',num2str(EU2{2}.meta.j(i)));
            coeff_pars.m(counter) = 1;
            coeff_pars.j1(counter) = EU2{2}.meta.j(i);
            coeff_pars.j2(counter) = J;
            coeff_pars.k2(counter)  = -1;
            coeff_pars.theta2_minus_theta1(counter) = -1;
            coeff_pars.moment(counter) = 2;
            counter = counter + 1;
        end
    end
    
    % Layer 2
    if length(EU1) > 2
        
        L = max(EU1{3}.meta.theta2_minus_theta1)+1; 
        
        for i=1:size(EU1{3}.meta.j,2)
            coeff_names{counter} = strcat('L1^1_m=2_j1=',...
                num2str(EU1{3}.meta.j(1,i)),'_j2=',...
                num2str(EU1{3}.meta.j(2,i)),'_theta2_minus_theta1=',...
                num2str(EU1{3}.meta.theta2_minus_theta1(i)));
            if ~strcmpi(scat_type,'t')
                coeff_names{counter} = strcat(coeff_names{counter},...
                    '_k2=',num2str(EU1{3}.meta.k2(i)));
                coeff_pars.k2(counter) = EU1{3}.meta.k2(i);
            else
                coeff_names{counter} = strcat(coeff_names{counter},...
                    '_k2=',num2str(log2(L)));
                coeff_pars.k2(counter) = log2(L);
            end
            coeff_pars.m(counter) = 2;
            coeff_pars.j1(counter) = EU1{3}.meta.j(1,i);
            coeff_pars.j2(counter) = EU1{3}.meta.j(2,i);
            coeff_pars.theta2_minus_theta1(counter) = EU1{3}.meta.theta2_minus_theta1(i);
            coeff_pars.moment(counter) = 1; 
            counter = counter + 1;
            
            if nargin > 2
                coeff_names{counter} = strcat('L2^2_m=2_j1=',...
                    num2str(EU2{3}.meta.j(1,i)),'_j2=',...
                    num2str(EU2{3}.meta.j(2,i)),'_theta2_minus_theta1=',...
                    num2str(EU2{3}.meta.theta2_minus_theta1(i)));
                if ~strcmpi(scat_type,'t')
                    coeff_names{counter} = strcat(coeff_names{counter},...
                        '_k2=',num2str(EU2{3}.meta.k2(i)));
                    coeff_pars.k2(counter) = EU2{3}.meta.k2(i);
                else
                    coeff_names{counter} = strcat(coeff_names{counter},...
                        '_k2=',num2str(log2(L)));
                    coeff_pars.k2(counter) = log2(L);
                end
                coeff_pars.m(counter) = 2;
                coeff_pars.j1(counter) = EU2{3}.meta.j(1,i);
                coeff_pars.j2(counter) = EU2{3}.meta.j(2,i);
                coeff_pars.theta2_minus_theta1(counter) = EU2{3}.meta.theta2_minus_theta1(i);
                coeff_pars.moment(counter) = 2; 
                counter = counter + 1;                
            end
        end
    end
end

end