% Bastien Milani, September 2016, CHUV Lausanne
%
% This function allows for the manual selection of one polygon on a 
% background image and returns the inner-mask of the selected polygon as 
% well as the inner- and outer-boundaries inherent to the 
% concentric-object technique. 
%
% Usage :
%--------------------------------------------------------------------------
% If an image is already displayed in a figure : 
% [outBoundary1
%  outBoundary2 
%  outMask] = conObjBound_C;
% 
%--------------------------------------------------------------------------
% If argImage is a matrix of gray levels : 
% [outBoundary1
%  outBoundary2 
%  outMask] = conObjBound_C(argImage); 
%  
%--------------------------------------------------------------------------
% As the previous usage with the closing of the figure after the end of the
% selection : 
% [outBoundary1
%  outBoundary2 
%  outMask] = conObjBound_C(argImage,
%                           'close');
% 
%--------------------------------------------------------------------------
%
% outBoundary1 resp. outBoundary2 are 2xN matrices containing the x and y
% coordinates of the inner- resp. outer-boundary.   
%
% outMask is a logical matrix with the same size as the
% background figure used during the selection. This output argument can be
% omitted. 


function varargout = conObjBound_C(varargin)

if length(varargin) > 0
    myImage = varargin{1};
    standAloneFlag = 1;
    
    if isempty(myImage) || size(myImage, 1) == 1 || size(myImage, 2) == 1
        myError(nargout);
        return;
    end
    
    myFigure = conObjImage(myImage, 'figId');
else
    myFigure = gcf;
    myImage = getimage(gca);
    standAloneFlag = 0;
end

closeFlag = 0;
if length(varargin)>1
    if strcmp(varargin{2}, 'close')
        closeFlag = 1;
    end
end

myMask = [];
while isempty(myMask)
    if isvalid(myFigure)
        myMask = roipoly;
    else
        break;
    end
end


myBound = bwboundaries(myMask);
if length(myBound) == 0
    myError(nargout);
    return;
end

myBound = myBound{1};
if length(myBound) == 0
    myError(nargout);
    return;
end
myBound = fliplr(myBound)';
hold on
plot(myBound(1,:), myBound(2,:),'w');
myClims = get(gca,'CLim');

[myX myY] = conObjGetTwoPix;

if (sum(abs(myX(:))== 0)) || (sum(abs(myX(:))== 0))
    myError(nargout);
    return;
end

myDist1 = (myBound(1,:)-myY(1)).^2+(myBound(2,:)-myX(1)).^2;
myDist2 = (myBound(1,:)-myY(2)).^2+(myBound(2,:)-myX(2)).^2;

[myMin1 myIndex1] = min(myDist1);
[myMin2 myIndex2] = min(myDist2);

if myIndex1 == myIndex2
    myError(nargout);
    return;
end

if myIndex1 > myIndex2
    temp = myIndex1;
    myIndex1 = myIndex2;
    myIndex2 = temp;
end

myBound1 = myBound(:, myIndex1:myIndex2);
myBound2 = horzcat(myBound(:, myIndex2:end), myBound(:, 2:myIndex1));

myMask1 = roipoly(myImage, myBound1(1,:), myBound1(2,:));
myMask2 = roipoly(myImage, myBound2(1,:), myBound2(2,:));

if sum(myMask1(:)) < sum(myMask2(:))
    temp = myBound1;
    myBound1 = myBound2;
    myBound2 = temp;
end

if myBound1(2,1) < myBound1(2,end)
    myBound1 = fliplr(myBound1);
end

if myBound2(2,1) < myBound2(2,end)
    myBound2 = fliplr(myBound2);
end

if standAloneFlag
    hold off
    imagesc(myImage(:,:,1))
    axis image
    caxis(myClims);
end

hold on
plot(myBound1(1,:), myBound1(2,:),'r');
plot(myBound2(1,:), myBound2(2,:),'b');

varargout{1} = myBound1;
varargout{2} = myBound2;
varargout{3} = myMask;

if closeFlag
    delete(gcf);
end

    function myError(n)
        for ii = 1:n
            varargout{ii} = 0;
        end
        errordlg('Wrong list of arguments or wrong selection !');
        if standAloneFlag || closeFlag
            delete(gcf);
        end
        
    end



end




