% OPTIMIZE_FILTER Optimize filter representation
%
% Usage
%    filter = OPTIMIZE_FILTER(filter_f, lowpass, options)
%
% Input
%    filter_f (numeric): The Fourier transform of the filter.
%    lowpass (boolean): If true, filter_f contains a lowpass filter.
%    options (struct): Various options on how to optimize the filter:
%       options.filter_format (char): Specifies the type of optimization, 
%          either 'fourier', 'fourier_multires' or 'fourier_truncated'. See 
%          description for more details.
%
% Output
%    filter (struct or numeric): The optimized filter structure.
%
% Description
%    Depending on the value of options.filter_format, OPTIMIZE_FILTER calls
%    different functions to optimize the filter representation. If 'fourier',
%    the function retains the Fourier representation of the filter. If 
%    'fourier_multires', the filter is periodized and stored at all resolu-
%    tions using PERIODIZE_FILTER. 
%
% See also 
%    PERIODIZE_FILTER

function filter = optimize_filter(filter_f, lowpass, options)
	options = fill_struct(options,'filter_format','fourier_multires');

	if strcmp(options.filter_format,'fourier')
		filter = filter_f;
	elseif strcmp(options.filter_format,'fourier_multires')
		filter = periodize_filter(filter_f);
	else
		error(sprintf('Unknown filter format ''%s''',options.filter_format));
	end
end
