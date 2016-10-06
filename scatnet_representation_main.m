 % This is the main script to compute a scattering representation, given
% options.

% If set to 1, this variable recomputes precomputed features for a given
% option.
recompute=1;

% Clear every previous batch of the works
clear jobs
fprintf('Load options...\n');
% Folders to save data are created according to the given options
createjobfolder(option,mergestruct(option.Exp));
nameJobFile=getnamejobfile(option,0,mergestruct(option.Exp));
savepar(nameJobFile,'option',option);

% Create the config specific to the dataset
[class,getImage,score_function,split_function,Wop,Wop_color,filt_opt,filt_opt_color]=recover_dataset(option);

% Batch the dataset
nImages=numel(class);
k=1;

for ii=1:option.General.numJobPerWorker:nImages
    % jobs{k} contain the index of the images to process at the k-th process
    jobs{k}=ii:min(nImages,ii+option.General.numJobPerWorker-1);
    k=k+1;
end

fprintf('Batch...\n');

createjobfolder(option,mergestruct(option.Exp,option.Layers));

tic % We compute the scattering features
for i=1:length(jobs)
    nameJobFile=getnamejobfile(option,i,mergestruct(option.Exp,option.Layers));
    if ~exist(nameJobFile, 'file') || recompute
        for j=1:length(jobs{i})
            
            % Image reader
            imageData=getImage(jobs{i}(j)); % The images are resized using bilinear interpolation
            imageData=double(imageData);
            yYUV=zeros(size(imageData),'single');
            
            % If image is not color - happens only in Caltech
            if(ismatrix(imageData))
                yYUV(:,:,1)=single(imageData);
                yYUV(:,:,2)=0;
                yYUV(:,:,3)=0;
                yYUV=single(yYUV);
            else
                yYUV =single(rgb2yuv(imageData))               
            end
            imy=yYUV(:,:,1);
            imu=yYUV(:,:,2);
            imv=yYUV(:,:,3);
            
            imy=imresize(imy,[option.Layers.size,option.Layers.size]);
            imu=imresize(imu,[option.Layers.size_color,option.Layers.size_color]);
            imv=imresize(imv,[option.Layers.size_color,option.Layers.size_color]);
            
            
            if(option.Layers.color==1)
                S_y, U_y=scat(imy,Wop);
                S_u=scat(imu,Wop_color);
                S_v=scat(imv,Wop_color);
                S_y_coeff=format_scat(S_y,'order_table');
                S_u_coeff=format_scat(S_u,'order_table');
                S_v_coeff=format_scat(S_v,'order_table');
                S_y_coeff=[S_y_coeff{1}(:);S_y_coeff{2}(:);S_y_coeff{3}(:)];
                S_u_coeff=[S_u_coeff{1}(:);S_u_coeff{2}(:);S_u_coeff{3}(:)];
                S_v_coeff=[S_v_coeff{1}(:);S_v_coeff{2}(:);S_v_coeff{3}(:)];
                S_coeff=[S_y_coeff;S_u_coeff;S_v_coeff];
            else
                S_y=scat(imy,Wop);
                S_y_coeff=format_scat(S_y,'order_table');
                S_y_coeff=[S_y_coeff{1}(:);S_y_coeff{2}(:);S_y_coeff{3}(:)];
                S_coeff=[S_y_coeff];
            end

            if(j==1)
                scatteringFeature=zeros([length(jobs{i}),numel(S_coeff)],'single');
            end         
            scatteringFeature(j,:)=S_coeff(:);
        end
        % Save the computed features in a folder
        savepar(nameJobFile,'intermediateScatteringVector',scatteringFeature);
    end
end
fprintf(' .');

timeScat=toc;

if(recompute)
    fprintf('(recomputed)');
end
fprintf(['\nScat layer processed in ' num2str(timeScat) 's\n']);

k=1;
tic

recompute=1;% Put the features in the memory

% Batch the features in memory
if recompute
    for i=1:length(jobs)
        nameJobFile=getnamejobfile(option,i,mergestruct(option.Exp,option.Layers));
        scatFeature=loadpar(nameJobFile,'intermediateScatteringVector');

        if(k==1)
            scattering_representation=zeros(nImages,size(scatFeature,2),'single');
        end
        scattering_representation(k:k+size(scatFeature,1)-1,:)=scatFeature;
        k=k+size(scatFeature,1);
        

        fprintf('. ');
        if(mod(i,20)==0)
            fprintf('\n');
        end
    end
    

    fprintf('\nLog+standardization');
    % Apply log non-linearity - abs is for the few negative values(that 
    % comes from round-off errors and to remove them from the representation.
    scattering_representation=log(abs(scattering_representation)+1e-6);

    % Standardize the representation
    scattering_representation=standardize_feature(scattering_representation);
end

% Reduce dimension + Classification framework
dimension_reduction_and_SVM