function out = max300ize(in)
% 18 dec 2012 - laurent sifre
% resizes image with maximum width of 300 and preserves aspect ratio
[n,m] = size(in);
if m>300
   size_out = ceil([n,m] * 300 / m );
   out = imresize_notoolbox(in, size_out);
else
    out = in;
end