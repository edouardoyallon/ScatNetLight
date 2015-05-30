% WAVELET_LAYER_ROTOTRANS Compute the roto-translation wavelet transform of a scattering layer
%
% Usage
%   [U_Phi, U_Psi] = WAVELET_LAYER_3D(U, filters_space, filters_rot, options_space, options_rot)
%
% Input
%   U (struct): input scattering layer
%   filters_spce (struct): 2d filter bank to apply along spatial variable
%   filters_rot (struct): 1d filter bank to apply along orientation
%   options_space (struct): option of the WT along space
%   options_rot (struct): option of the WT along angles
%
% Output
%   U_Phi (struct): low pass convolutions of all signal of layer U
%   U_Psi (struct): high pass convolutions of all signal of layer U
%
% Description
%   This function will compute all the roto-translation wavelet transform
%   of signals contained in the input layer U.
%


function [U_Phi, U_Psi] = wavelet_layer_2_rototrans(U, filters_space, filters_rot, options_space, options_rot)

% do not compute any convolution
% with psi if the user does get U_psi
calculate_psi = (nargout>=2);


% 1 if the averaging is also along angle and space. 0 otherwise.
output_avg=options_rot.output_averaging;

% Separable or non separable convolution?
is_separable=strcmp(options_space.type,'tr');

p_rotospace=1;
p_space=1;
p_phi=1;

% Wavelet transform along space
for p = 1:numel(U.signal)
    y = U.signal{p};
    j = U.meta.j(end,p);
    
    options_space.psi_mask = calculate_psi & ...
        (filters_space.psi.meta.j >= j + 1);
    
    % compute mask for progressive paths
    options_space.x_resolution = U.meta.resolution(p);
    
    if (calculate_psi)
        [y_Phi_space, y_Psi_space, meta_Phi_space, meta_Psi_space] = wavelet_2d(y, filters_space, options_space);
        
        for p_psi = find(options_space.psi_mask)
            U_Psi_space.signal{p_space} = y_Psi_space{p_psi};
            U_Psi_space.meta.j(:,p_space) = [j;...
                filters_space.psi.meta.j(p_psi)];
            U_Psi_space.meta.theta(p_space) =  filters_space.psi.meta.theta(p_psi);
            U_Psi_space.meta.resolution(p_space) = meta_Psi_space.resolution(p_psi);
            p_space = p_space +1;
        end
    else
        % Average along SPACE
        [y_Phi_space,~,meta_Phi_space,~] = wavelet_2d(y, filters_space,options_space);
    end
   
    U_Phi_space.signal{p} = y_Phi_space;
    U_Phi_space.meta.j(:,p) = [U.meta.j(:,p); filters_space.meta.J];
    U_Phi_space.meta.resolution(p) = meta_Phi_space.resolution;
end

% The previous layer is the 2D one, thus we regroup the output according to
% their scale since they are all at the same resolution

meta_j1{1}=1:numel(U_Phi_space.meta.j(1,:));
U_Phi_space.meta.j=filters_space.meta.J;
U_Phi_space.meta.resolution=meta_Phi_space.resolution;
U_Phi_space.signal=format_orbit(U_Phi_space.signal,meta_j1,4);

% If it is the non separable rototranslation framework, then we have to output 2
% times the number of angles, for energy conservation(sqrt(2) is for that!).
if(options_rot.output_averaging && ~is_separable)
    U_Phi_space.signal{1}=get_half_angles2(U_Phi_space.signal{1},3)/sqrt(2);
end

% If we have to compute the convolution with bandpass filters, we begin by
% reshape all the results from wavelet_2d to perform computations along angle.
% This is necessary and makes the program clearer. Besides we regroup elements by scales
if (calculate_psi)
    % First regroup by angles then angles
    k=1;
    scales_j2=unique(U_Psi_space.meta.j(2,:));
    for i=1:length(scales_j2);
        scales_j1=unique(U_Psi_space.meta.j(1,(U_Psi_space.meta.j(2,:)==scales_j2(i))));
        for j=1:length(scales_j1)
            theta_1=unique(U_Psi_space.meta.theta);
            for theta=1:length(theta_1)
                meta_theta{k}(theta)=find(...
                    U_Psi_space.meta.theta==theta_1(theta) & U_Psi_space.meta.j(1,:)==scales_j1(j)...
                    & U_Psi_space.meta.j(2,:)==scales_j2(i));
            end
            U_Psi_space_formated_theta.meta.j(1,k)=scales_j1(j);
            U_Psi_space_formated_theta.meta.j(2,k)=scales_j2(i);
            U_Psi_space_formated_theta.meta.resolution(k)=U_Psi_space.meta.resolution(meta_theta{k}(1));
            
            k=k+1;
        end
    end
    
    
    U_Psi_space_formated_theta.signal=format_orbit(U_Psi_space.signal,meta_theta,4);
    
    % Then concatenate the all the j1<j2 together in the same j2
    k=1;
    scales_j2=unique(U_Psi_space_formated_theta.meta.j(2,:));
    for i=1:length(scales_j2);
        scales_j1=unique(U_Psi_space_formated_theta.meta.j(1,(U_Psi_space_formated_theta.meta.j(2,:)==scales_j2(i))));
        for j=1:length(scales_j1)
            meta_j2{k}(j)=find( U_Psi_space_formated_theta.meta.j(1,:)==scales_j1(j)...
                & U_Psi_space_formated_theta.meta.j(2,:)==scales_j2(i));
        end
        Uorb_space.meta.j(1,k)=scales_j2(i);
        Uorb_space.meta.resolution(k)=U_Psi_space_formated_theta.meta.resolution(meta_j2{k}(1));
        k=k+1;
    end
    
    
    
    Uorb_space.signal=format_orbit(U_Psi_space_formated_theta.signal,meta_j2,5);
    
    
    % Wavelet transform along angles
    for p_r=1:numel(Uorb_space.signal)
        
        y = Uorb_space.signal{p_r};
        
        % If not separable, make it separable - it will double the angle in
        % theta_1 by performing the correct reshaping of the matrix
        if(~is_separable)
            y=reshape_rototranslation_nonseparable(y);
        end

        % Conjugate to get the negative frequency!
        y=get_negative_frequency(y);

        [y_Phi_angle_Psi_space, y_Psi_angle_Psi_space,meta_Phi_angle_Psi_space,meta_Psi_angle_Psi_space] = wavelet_1d(y, filters_rot, options_rot,3);
        
        for p_psi = 1:length(y_Psi_angle_Psi_space)
            U_Psi.signal{p_rotospace} = y_Psi_angle_Psi_space{p_psi};
            U_Psi.meta.j(p_rotospace) = Uorb_space.meta.j(p_r);
            U_Psi.meta.lambda_theta(p_rotospace) = filters_rot.psi.meta.k(p_psi);
            U_Psi.meta.resolution(p_rotospace) =  Uorb_space.meta.resolution(p_r);
            U_Psi.meta.resolution_theta(p_rotospace) =meta_Psi_angle_Psi_space.resolution(p_psi);
            p_rotospace = p_rotospace +1;
        end
        U_Psi.signal{p_rotospace}=y_Phi_angle_Psi_space;
        U_Psi.meta.j(p_rotospace)=Uorb_space.meta.j(p_r);
        U_Psi.meta.lambda_theta(:,p_rotospace)=filters_rot.meta.J;
        U_Psi.meta.resolution(p_rotospace) = Uorb_space.meta.resolution(p_r);
        U_Psi.meta.resolution_theta(p_rotospace) = meta_Phi_angle_Psi_space.resolution;
        p_rotospace=p_rotospace+1;
    end
end

% If we need to compute the averaging phi_space phi_angle
if(output_avg)
    for p_phi_space=1:length(U_Phi_space.signal)
        y = U_Phi_space.signal{p_phi_space};
        
        if(calculate_psi)
            [y_Phi_angle_Phi_space, y_Psi_angle_Phi_space,meta_Phi_angle_Phi_space,meta_Psi_angle_Phi_space] = wavelet_1d(y, filters_rot, options_rot,3);
            for p_psi = 1:length(y_Psi_angle_Phi_space)
                U_Psi.signal{p_rotospace} = y_Psi_angle_Phi_space{p_psi};
                U_Psi.meta.j(p_rotospace) = U_Phi_space.meta.j(p_phi_space);
                U_Psi.meta.lambda_theta(p_rotospace) = filters_rot.psi.meta.k(p_psi);
                U_Psi.meta.resolution(p_rotospace) =  U_Phi_space.meta.resolution(p_phi_space);
                U_Psi.meta.resolution_theta(p_rotospace) =meta_Psi_angle_Phi_space.resolution(p_psi);
                p_rotospace = p_rotospace +1;
            end
        else
            [y_Phi_angle_Phi_space,~,meta_Phi_angle_Phi_space,~] = wavelet_1d(y, filters_rot, options_rot,3);
        end
        U_Phi.signal{p_phi}=y_Phi_angle_Phi_space;
        U_Phi.meta.j(:,p_phi)=U_Phi_space.meta.j(p_phi);
        U_Phi.meta.lambda_theta(:,p_phi)=filters_rot.meta.J;
        U_Phi.meta.resolution(p_phi) = U_Phi_space.meta.resolution(p_phi_space);
        U_Phi.meta.resolution_theta(p_phi) = meta_Phi_angle_Phi_space.resolution;
        p_phi=p_phi+1;
    end
else
    U_Phi=U_Phi_space;
end
if (calculate_psi)
    % Final tensor thus we update the meta layer
    U_Psi.meta.layer=U.meta.layer+1;
end
end


