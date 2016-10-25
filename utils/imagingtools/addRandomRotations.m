function xaug = addRandomRotations(x, nrot, mode)
    sz = size(x);
    xaug = zeros([sz(1) sz(2) sz(3) (1+nrot)*sz(4)]);
    xaug(:,:,:,1:sz(4)) = x;
    ct = 1;
    for r = 1:nrot
        angle = rand(1,1) * 360;
        xpad=padarray(x, [16 16], 'symmetric');
        xrot=imrotate(xpad, angle, 'crop', mode);
        xcrop=xrot(16:47,16:47,:,:);
        p = sz(4)*ct;
        e = p + sz(4);
        p
        e
        
        xaug(:,:,:,p+1:e) = xcrop;
        ct = ct + 1;
    end
end