load_path_software
option=create_config_cifar_10('carmine')



% Clear every previous batch of the works
clear jobs
fprintf('Load options...\n');

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

cnt=1;
tic % We compute the scattering features
for i=1:length(jobs)
    nameJobFile=getnamejobfile(option,i,mergestruct(option.Exp,option.Layers));
    for j=1:length(jobs{i})
        disp(sprintf ('processing image n. %d/%d', cnt, nImages))
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
            yYUV =single(rgb2yuv(imageData));               
        end
        imy=yYUV(:,:,1);
        imu=yYUV(:,:,2);
        imv=yYUV(:,:,3);

        imy=imresize(imy,[option.Layers.size,option.Layers.size]);
        imu=imresize(imu,[option.Layers.size_color,option.Layers.size_color]);
        imv=imresize(imv,[option.Layers.size_color,option.Layers.size_color]);

        image{1} = imy; image{2} = imu; image{3} = imv;
        if(option.Layers.color==1)
            [~, U_y] =scat(imy,Wop);
            [~, U_u] =scat(imu,Wop_color);
            [~, U_v] =scat(imv,Wop_color);
            U_coeff{1} = U_v; U_coeff{2} = U_u; U_coeff{3} = U_y;
        else
            U_coeff{1} = U_y;
        end

        U_features{cnt} = U_coeff;
        all_images{cnt} = image;
        cnt = cnt + 1;
        if cnt == 10
			disp ('storing first 10')
			save('U_features_10_CIFAR10.mat', 'U_features')
			save('images_10_CIFAR10.mat', 'all_images')
            class10=class(1:10)
            save('labels_10_CIFAR10.mat', 'class10')
		end
    end
end
fprintf(' .');

timeScat=toc;

disp('storing files')
save('U_features_CIFAR10.mat', 'U_features')
save('all_images_CIFAR10.mat', 'all_images')
save('labels_CIFAR10.mat', 'class')

