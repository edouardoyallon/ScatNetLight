% UNWIND_EXP_SCAT_2D
% Unwinds the expected scattering coefficients to be used in regression 
%   tasks. Also returns the scattering names and parameters for the unwound
%   matrix.
%
% Usage:
%   [X, coeff_names, coeff_pars] = UNWIND_EXP_SCAT_2D(EU, scat_type, field_val, field_name)
%
% Inputs:
%   1.) EU (cell): Each EU{i} is a cell of expected scattering 
%       coefficients, as outputted by EXPECTED_SCAT_LIGHT_2D.
%   2.) scat_type (cell): Each scat_type{i} is a string indicating the 
%       scattering type of EU{i}, either 't', 'tr', or 'tr_nonsep'.
%   3.) field_val (cell): Optional additional meta information. Each
%       field_val{i} corresponds to EU{i}.
%   4.) field_name (string): The name of the extra meta information in
%       field_val.
%
% Outputs:
%   1.) X (numeric): Matrix of scattering coefficients. Rows are data
%       points, columns are scattering features.
%   2.) coeff_names (cell): Contains strings with the names of each
%       scattering feature.
%   3.) coeff_pars (struct): Struct containing fields with different
%       scattering parameters, and their value for each scattering feature.
%
% See also:
%   EXPECTED_SCAT_LIGHT_2D
%
% This file is part of ScatNetLight.
% Author: Matthew Hirn
% email: matthew.hirn@ens.fr


function [X, coeff_names, coeff_pars] = unwind_exp_scat_2d(EU,scat_type,field_val,field_name)

% Collect inputs
num_sets = length(EU);
if nargin < 4
    field_name = [];
end

% Unwind scattering
X = [];
for i=1:num_sets
    for m=1:length(EU{i})
        X = cat(2,X,EU{i}{m}.signal);
    end
end

% Coefficient names and parameters
coeff_names = cell(1,size(X,2));
coeff_pars.m = zeros(1,size(X,2));
coeff_pars.j1 = zeros(1,size(X,2));
coeff_pars.j2 = zeros(1,size(X,2));
coeff_pars.theta2_minus_theta1 = zeros(1,size(X,2));
coeff_pars.k2 = zeros(1,size(X,2));
coeff_pars.moment = zeros(1,size(X,2));
coeff_pars.scat_type = cell(1,size(X,2));
if ~isempty(field_name)
    coeff_pars.(field_name) = cell(1,size(X,2));
end

counter = 1;
for i=1:num_sets
    
    % Moment and number of layers
    p = EU{i}{1}.meta.moment;
    M = length(EU{i})-1;
    
    % Layer 0
    coeff_names{counter} = strcat('L',num2str(p),'^',num2str(p),'_m=0');
    coeff_pars.m(counter) = 0;
    coeff_pars.j1(counter) = -1;
    coeff_pars.j2(counter) = -1;
    coeff_pars.k2(counter) = -1;
    coeff_pars.theta2_minus_theta1(counter) = -1;
    coeff_pars.moment(counter) = p;
    coeff_pars.scat_type{counter} = scat_type{i};
    if ~isempty(field_name)
        coeff_names{counter} = strcat(coeff_names{counter},'_',field_val{i});
        coeff_pars.(field_name){counter} = field_val{i};
    end
    counter = counter + 1;
    
    % Layer 1
    if M > 0
        for j=1:length(EU{i}{2}.meta.j)
            coeff_names{counter} = strcat('L',num2str(p),'^',num2str(p),...
                '_m=0_j1=',num2str(EU{i}{2}.meta.j(j)));
            coeff_pars.m(counter) = 1;
            coeff_pars.j1(counter) = EU{i}{2}.meta.j(j);
            coeff_pars.j2(counter) = -1;
            coeff_pars.k2(counter)  = -1;
            coeff_pars.theta2_minus_theta1(counter) = -1;
            coeff_pars.moment(counter) = p;
            coeff_pars.scat_type{counter} = scat_type{i};
            if ~isempty(field_name)
                coeff_names{counter} = strcat(coeff_names{counter},'_',field_val{i});
                coeff_pars.(field_name){counter} = field_val{i};
            end
            counter = counter + 1;
        end
    end
    
    % Layer 2
    if M > 1
        for j=1:size(EU{i}{3}.meta.j,2)
            coeff_names{counter} = strcat('L',num2str(p),'^',...
                num2str(p),'_m=2_j1=',num2str(EU{i}{3}.meta.j(1,j)),...
                '_j2=',num2str(EU{i}{3}.meta.j(2,j)),...
                '_theta2_minus_theta1=',...
                num2str(EU{i}{3}.meta.theta2_minus_theta1(j)));
            if ~strcmpi(scat_type{i},'t')
                coeff_names{counter} = strcat(coeff_names{counter},...
                    '_k2=',num2str(EU{i}{3}.meta.k2(j)));
            end
            coeff_names{counter} = strcat(coeff_names{counter},'_',scat_type{i});
            coeff_pars.m(counter) = 2;
            coeff_pars.j1(counter) = EU{i}{3}.meta.j(1,j);
            coeff_pars.j2(counter) = EU{i}{3}.meta.j(2,j);
            if strcmpi(scat_type{i},'t')
                coeff_pars.k2(counter)  = -1;
            else
                coeff_pars.k2(counter) = EU{i}{3}.meta.k2(j);
            end
            coeff_pars.theta2_minus_theta1(counter) = EU{i}{3}.meta.theta2_minus_theta1(j);
            coeff_pars.moment(counter) = p;
            coeff_pars.scat_type{counter} = scat_type{i};
            if ~isempty(field_name)
                coeff_names{counter} = strcat(coeff_names{counter},'_',field_val{i});
                coeff_pars.(field_name){counter} = field_val{i};
            end
            counter = counter + 1;
        end
    end
    
end

end