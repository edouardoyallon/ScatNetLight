
function haar = haar_2d(N, M, L, scale,offset)
	
	if ~exist('offset','var')
		offset = [0,0];
	end
	
	
	[x , y] = meshgrid(1:M,1:N);
	x = x - ceil(M/2) - 1;
	y = y - ceil(N/2) - 1;
	x = x - offset(1);
	y = y - offset(2);
	scale=scale+1;
    haar=zeros(N,M);
    if(L==4)
    haar(-2^(scale-1)<=x & x<2^(scale-1) & -2^(scale-1)<=y & y<2^(scale-1))=1;
    elseif(L==2)
        haar(-2^(scale-1)<=x & x<2^(scale-1) & -2^(scale-1)<=y & y<2^(scale-1))=1;
        haar(-2^(scale-1)<=x & x<0 & -2^(scale-1)<=y & y<0)=-1;
        haar(x<2^(scale-1) & x>=0 & 2^(scale-1)>y & y>=0)=-1;
        
        
        
    elseif(L==3)
    haar(-2^(scale-1)<=x & x<2^(scale-1) & -2^(scale-1)<=y & y<2^(scale-1))=1;
    haar(-2^(scale-1)<=y & y<2^(scale-1) & x>=-2^(scale-1) &x<0)=-1;
    elseif(L==1)
        haar(-2^(scale-1)<=x & x<2^(scale-1) & -2^(scale-1)<=y & y<2^(scale-1))=1;
    haar(-2^(scale-1)<=x & x<2^(scale-1) & y>=-2^(scale-1) &y<0)=-1;
    else
        error('BUG');
    end
    
    haar=haar/2^(2*scale);

end