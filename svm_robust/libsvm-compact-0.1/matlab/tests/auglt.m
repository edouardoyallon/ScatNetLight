function y = auglt(x)
	y = zeros(sum(x(:,1))+1,1,class(x));
	r = 1;
	for k = 1:size(x,1)
		y(r:r+x(k,1)) = x(k,1:x(k,1)+1);
		r = r+x(k,1)+1;
	end
end