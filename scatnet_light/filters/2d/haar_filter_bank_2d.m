
function filters = haar_filter_bank_2d(size_in, options)
    if(nargin<2)
		options = struct;
    end
if(nargin<3)
isGPU=0;
end
if(nargin<4)
    isComplex=0;
end

    white_list = {'Q',  'J', 'min_margin', 'precision', ...
		'filter_format'};
    check_options_white_list(options, white_list);
    
    % Options
    options = fill_struct(options, 'Q',1);	
    options = fill_struct(options, 'J',4);
    J = options.J;
    Q = options.Q;
    
	options = fill_struct(options, 'filter_format', 'fourier_multires');
    options = fill_struct(options, 'min_margin', 2^(J/Q) );
    options = fill_struct(options, 'precision', 'single');
    
    
    switch options.precision
        case 'single'
            cast = @single;
        case 'double'
            cast = @double;
        otherwise
            error('precision must be either double or single');
    end
    
    % Size
    res_max = floor(J/Q);
    size_filter = pad_size(size_in, options.min_margin, res_max);
	phi.filter.type = 'fourier_multires';
	
	% Compute all resolution of the filters
	res = 0;
	
	N = size_filter(1);
	M = size_filter(2);
	
	% Compute low-pass filters phi
	%scale = 2^((J-1) / Q - res);

filter_spatial =  single(haar_2d(N, M, 4,(J-1)/Q-res));

	phi.filter = cast(fft2(filter_spatial));
	phi.meta.J = J;
	
	phi.filter = optimize_filter(phi.filter, 1, options);
	
	littlewood_final = zeros(N, M);
	
	p = 1;
	for j = 0:J-1
		for theta = 1:3			

		%	scale = 2^(j/Q - res);
			filter_spatial = haar_2d(N,M,theta,j);
				% SLIGHT MODIF
if(isGPU)
			psi.filter{p} = gpuArray(single(cast(fft2(filter_spatial))));
else
		psi.filter{p} = single(cast(fft2(filter_spatial)));
end
			
			littlewood_final = littlewood_final + ...
				abs(realize_filter(psi.filter{p})).^2;
			
			psi.meta.j(p) = j;
			psi.meta.theta(p) = theta;
			p = p + 1;
		end
	end
	
	% Second pass : renormalize psi by max of littlewood paley to have
	% an almost unitary operator
	% NB : phi must not be renormalized since we want its mean to be 1
	K = max(littlewood_final(:));
	for p = 1:numel(psi.filter)
		psi.filter{p} = psi.filter{p}/sqrt(K/2);
		psi.filter{p} = optimize_filter(psi.filter{p}, 0, options);
	end
	
	filters.phi = phi;
	filters.psi = psi;
	
	filters.meta.Q = Q;
	filters.meta.J = J;
	filters.meta.L = 3;
	filters.meta.size_in = size_in;
	filters.meta.size_filter = size_filter;
end