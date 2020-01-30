% Bastien Milani, September 2016, CHUV Lausanne
%
% This function performs a mono-exponential fit either by the use of the
% lsqcurvefit build-in function of Matlab or by computing the least square
% line of the logarithm of the data. 
%
% Usage : 
%
% [exp_map amp_map varargout] = conObjMonoExpFit(argImagesTable, argX, varargin)
%
% argImagesTable can be any array of any size [s_1, ..., s_N] 
%
% argX must be a one dimensional array with a length equal to the size of
% the last dimension of argImagesTable i.e. s_N. 
%
% exp_map is an array of size [s_1, ... , s_(N-1)]. It contains the decay
% constants of the fitted mono-exponential decays.
%
% amp_map is an array of size [s_1, ... , s_(N-1)]. It contains the 
% amplitudes of the fitted mono-exponential decays.
%
% The first item of the list of optional input arguments varargin is a 
% tolerance for the root-mean-squared relative error of the data to the fit.
% If this tolerance is exceeded for a given decay, the values exp_map and 
% amp_map for this decay will be set to NaN. 
%
% The second item of varargin is a lower bound for exp_map. If exp_map
% appears to be smaller than this bound, it is set to NaN. 
%
% The third item of varargin is an upper bound for exp_map. If exp_map
% appears to be bigger than this bound, it is set to NaN. 
%
% One or more of these three argument can be replaced with empty brackets. 
%
% The fourth item can be set to 'Fit' and the fifth to 'lsqcurvefit' to
% perform a fit with the lsqcurvefit function of matlab. If this option is
% omitted, an affine fit of the logarithm of the data is performed. 
%
% The first item of the list of optional output arguments varargout 
% is an array of the same size as argImagesTable. It contains the fitted
% values to be compared with the data stored in argImagesTable. 
%
% The second item is a mask with the same size as exp_map and amp_map. It
% contains 1 where exp_map and amp_map where set to NaN and zero
% elsewhere. 
%
% Examples : 
% [exp_map, amp_map, ~, NanMask]      = conObjMonoExpFit(argImagesTable, argX, 0.1, 10, 50);
% [exp_map, amp_map, myFit, NanMask]  = conObjMonoExpFit(argImagesTable, argX, 0.1, 10, 50);
% [exp_map, amp_map, ~, NanMask]      = conObjMonoExpFit(argImagesTable, argX, [], 10, 50);
% [exp_map, amp_map, ~, NanMask]      = conObjMonoExpFit(argImagesTable, argX, [], [], [], 'Fit', 'lsqcurvefit');


function [b_map a_map varargout] = conObjMonoExpFit(argImagesTable, argX, varargin)

    mySize = size(argImagesTable);
    mySize = [prod(mySize(1:end-1)) mySize(end)]; 
    
    if not(length(argX) == mySize(2))
        a_map = 0; 
        b_map = 0; 
        errordlg('Wrong list of arguments'); 
        return;  
    end

    errorTh = [];
    lowerBound = [];
    upperBound = []; 
    lsqLowerBound = [];
    lsqUpperBound = []; 
    lsqcurvefitFlag = 0; 
    
    if length(varargin) == 0
        1+1;
    elseif length(varargin) == 1
        errorTh = varargin{1}; 
    elseif length(varargin) == 3 
        errorTh = varargin{1}; 
        lowerBound = varargin{2}; 
        upperBound = varargin{3}; 
    elseif length(varargin) == 5 
        errorTh = varargin{1}; 
        lowerBound = varargin{2}; 
        upperBound = varargin{3}; 
        if strcmp(varargin{4},'Fit') && strcmp(varargin{5},'lsqcurvefit')
            lsqcurvefitFlag = 1; 
        else
            errordlg('Wrong list of arguments. ');
        end
    elseif length(varargin) == 7
        errorTh = varargin{1}; 
        lowerBound = varargin{2}; 
        upperBound = varargin{3}; 
        if strcmp(varargin{4},'Fit') && strcmp(varargin{5},'lsqcurvefit')
            lsqcurvefitFlag = 1;
            lsqLowerBound = varargin{6};
            lsqUpperBound = varargin{7};
        end
    else
        a_map = 0; 
        b_map = 0; 
        errordlg('Wrong list of arguments'); 
        return;
    end


    %definition of the fit-model for mono-exponential fitting
    mdl_mono_exp = @(beta,x)(beta(1)*exp(-x*beta(2)));


    %options for the fitting function
    opts = optimset('Display', 'off');
    
    imagesTable = reshape(argImagesTable, mySize); 
    iMax = mySize(2); 
    x = squeeze(argX)'; 

    a_map   = zeros(mySize(1), 1);
    b_map   = zeros(mySize(1), 1);

    
    xTable = reshape(x, [1 length(x)]); 
    xTable = repmat(xTable, [mySize(1) 1]); 
    zTable = log(imagesTable);
    
    MeanX = mean(xTable, 2);
    MeanZ = mean(zTable, 2);
    MeanX2 = mean(xTable.^2, 2);
    MeanXZ = mean(xTable.*zTable, 2);

    h = (MeanX2.*MeanZ-MeanX.*MeanXZ)./(MeanX2-MeanX.^2);
    aStartTable = exp(h);
    bStartTable = -(MeanXZ-MeanX.*MeanZ)./(MeanX2-MeanX.^2); 
    
    a_map = aStartTable; 
    b_map = bStartTable; 
    
    if lsqcurvefitFlag
        for i = 1:mySize(1)
                if isnan(aStartTable(i))||isnan(bStartTable(i))
                    a_map(i) = NaN;
                    b_map(i) = NaN;
                else
                    y = squeeze(imagesTable(i, :))';
                    
                    beta = [aStartTable(i) bStartTable(i)];
                    beta = lsqcurvefit(mdl_mono_exp , beta, x, y, lsqLowerBound, lsqUpperBound, opts);
                    a_map(i) = beta(1);
                    b_map(i) = beta(2);
            end
        end
    end
    
    a_map_table = repmat(a_map, [1 length(x)]); 
    b_map_table = repmat(b_map, [1 length(x)]); 
    
    myFit = a_map_table.*exp(-b_map_table.*xTable);
    myError = sqrt(mean((myFit-imagesTable).^2./myFit.^2,2));

    if not(isempty(errorTh))
        errorMask = (myError > errorTh);
    else
        errorMask = zeros(mySize(1), 1); 
    end
    errorMask = errorMask + isnan(a_map)+isnan(b_map); 
    errorMask = logical(errorMask);
    
    if not(isempty(lowerBound))
        errorMask = errorMask + (b_map < lowerBound); 
        errorMask = logical(errorMask); 
    end
    if not(isempty(upperBound))
        errorMask = errorMask + (b_map > upperBound); 
        errorMask = logical(errorMask);  
    end
    
    a_map(errorMask) = NaN; 
    b_map(errorMask) = NaN; 
    
    mySize = size(argImagesTable);
    mySize = mySize(1:end-1); 
    
    if ndims(argImagesTable) > 2
        errorMask = reshape(errorMask, mySize);
        a_map = reshape(a_map, mySize);
        b_map = reshape(b_map, mySize);
    end
    
    varargout{1} = reshape(myFit, size(argImagesTable)); 
    varargout{2} = errorMask; 
    
end
