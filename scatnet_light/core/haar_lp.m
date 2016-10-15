function h_x = haar_lp(x, subsample)
% 
% h_x = zeros(1, length(x));
% for i = 1:2:length(x)-1
%     h_x(i) = (x(i) + x(i+1)) / sqrt(2);
%     h_x(i+1)=h_x(i);
% end
% if subsample == true 
%     h_x=h_x[1:2:end];
% end\


tmp=(x(1:2:end,1:2:end,:,:,:,:,:,:,:)+x(2:2:end,1:2:end,:,:,:,:,:,:,:)+x(1:2:end,2:2:end,:,:,:,:,:,:,:)+x(2:2:end,2:2:end,:,:,:,:,:,:,:))/4;

if subsample
    h_x=tmp;
else
    h_x=zeros(size(x));
    h_x(1:2:end,1:2:end,:,:,:,:,:,:,:)=tmp;
    h_x(2:2:end,1:2:end,:,:,:,:,:,:,:)=tmp;
    h_x(1:2:end,2:2:end,:,:,:,:,:,:,:)=tmp;
    h_x(2:2:end,2:2:end,:,:,:,:,:,:,:)=tmp;
end

end