function xaug = addRandomRotations(x, nrot, mode)
    sz = size(x);
    xaug = zeros([sz(1) sz(2) sz(3) nrot*sz(4)]);
    ct = 0;
    for r = 1:nrot
        angle = rand(1,1) * 360;
        xrot=imrotate(x, angle, mode);
        p = sz(4)*ct;
        e = p + sz(4);
        xaug(:,:,:,p+1:e) = xrot;
        ct = ct + 1;
    end
end