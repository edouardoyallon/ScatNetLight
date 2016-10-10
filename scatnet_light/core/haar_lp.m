function h_x = haar_lp(x)

h_x = zeros(1, length(x));
for i = 1:2:length(x)-1
    h_x(i) = (x(i) + x(i+1)) / sqrt(2);
    h_x(i+1)=h_x(i);
end

end