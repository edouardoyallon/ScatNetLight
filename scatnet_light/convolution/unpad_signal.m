% UNPAD_SIGNAL Remove de padding from PAD_SIGNAL
%
% Usage
%    x = UNPAD_SIGNAL(y, resolution, target_sz, center)
%
% Input
%    y (numeric): The signal to be unpadded.
%    resolution (int): The resolution of the signal (as a power of 2), with
%        respect to the original, unpadded version.
%    target_sz (numeric): The size of the original, unpadded version. Combined
%        with resolution, the size of the output y is given by
%        target_sz.*2.*(-resolution).
%    center (boolean, optional): If true, extracts the center part of y, oth-
%        erwise extracts the (upper) left corner (default false).
%
% Output
%    x (numeric): The extracted unpadded signal
%
% Description
%    To handle boundary conditions, a signal is often padded using PAD_SIGNAL
%    before being convolved with CONV_SUB_1D or CONV_SUB_2D. After this, the
%    padding needs to be removed to recover a regular signal. This is achieved
%    using UNPAD_SIGNAL, which takes the padded, convolved signal y as input,
%    as well as its resolution relative to the original, unpadded version,
%    and the size of this original version. Using this, it extracts the
%    coefficients in y that correspond to the domain of the original signal.
%    If the center flag was specified during PAD_SIGNAL, it is specified here
%    again in order to extract the correct part.
%
% See Also
%    PAD_SIGNAL
function x = unpad_signal(x, res, target_sz, center,ix)
if nargin < 4
    center = 0;
end
if(nargin<5)
    ix=[1;2];
end

padded_sz = size(x);

%assert(numel(ix)==numel(res));

%padded_sz = padded_sz(1:length(target_sz));
%if(numel(padded_sz)>=ix)
    padded_sz = padded_sz(ix);
%else
%    padded_sz=1;
%end
offset = 0.*target_sz(ix);

if center
    offset = (padded_sz.*2.^res-target_sz(ix))/2;
end


offset_ds = floor(offset./2.^res);
target_sz_ds = 1+floor((target_sz(ix)-1)./2.^res);


% Pad signal
gen_idx.type = '()';


gen_idx.subs = cell(1,ndims(x));%repmat({':'},1,ndims(x));
gen_idx.subs(:)={':'};

idx=gen_idx;
for d=1:length(ix)
    idx.subs{ix(d)} = offset_ds(d)+(1:target_sz_ds(d));
end
x = subsref (x,idx);
end
