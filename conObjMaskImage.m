% Bastien Milani, September 2016, CHUV Lausanne
%
% This function displays a mask-list returned by the function conObjMask. 
%
% Usage : 
% conObjMaskImage(argMaskList, option)
%
% The argument 'option' can be omitted or set to 'jet' to use the
% jet-color-map. 
%



function conObjMaskImage(argConObjMask, varargin)

jetFlag = 0;
if length(varargin) > 0
    if strcmp(varargin{1}, 'jet')
        jetFlag = 1;
    end
end
n = size(argConObjMask, 3);


if jetFlag
    
    myImage = n*argConObjMask(:,:,1);
    for i = 2:n
        myImage = myImage+(n-i+1)*argConObjMask(:,:,i);
    end
    figure
    imagesc(myImage)
    axis image
    colormap jet;
else
    myImage = argConObjMask(:,:,1);
    for i = 2:n
        myImage = myImage+i*argConObjMask(:,:,i);
    end
    figure
    imagesc(myImage)
    axis image
end



end
