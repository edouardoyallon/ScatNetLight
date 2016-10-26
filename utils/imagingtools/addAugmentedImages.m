function xaug = addAugmentedImages(x, nrot, mode)
    sz = size(x);
    xaug = zeros([sz(1) sz(2) sz(3) (1 + nrot) * sz(4)]);
    xaug(:,:,:,1:sz(4)) = x;
    ct = 1;
    for r = 1:nrot
        angle = (rand(1, 1) * 20);
        xpad=padarray(x, [16 16], 'symmetric');
        xrot=imrotate(xpad, angle, 'crop', mode);
        zoom = (rand(1, 1) * sqrt(2)/2) + (sqrt(2)/2);
        xscale = imresize(xrot, zoom);
        middle = ceil(size(xscale, 1) / 2);
        xcrop=xscale(middle - 16:middle + 15, middle-16:middle+15, :, :);
        p = sz(4)*ct;
        e = p + sz(4);
        if (rand(1, 1) > .5)
            xcrop = flip(xcrop);
        end
        xaug(:, :, :, p+1:e) = xcrop;
        ct = ct + 1;
    end
end