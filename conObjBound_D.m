% Bastien Milani, September 2016, CHUV Lausanne
%
% This function allows for the manual selection of two polygons on a 
% background image and returns the inner-masks of the two selected 
% polygons as well as the inner- and outer-boundaries inherent to the 
% concentric-object-technique.
%
% Usage :
%--------------------------------------------------------------------------
% If an image is already displayed in a figure : 
% [outBoundary1
%  outBoundary2 
%  outMask1
%  outMask2] = conObjBound_D; 
%  
%--------------------------------------------------------------------------
% If argImage is a matrix of gray levels :
% [outBoundary1
%  outBoundary2 
%  outMask1
%  outMask2] = conObjBound_D(argImage); 
%   
%--------------------------------------------------------------------------
% As the previous usage with the closing of the figure after the end of the
% selection : 
% [outBoundary1
%  outBoundary2 
%  outMask1
%  outMask2] = conObjBound_D(argImage,
%                           'close');
%
%--------------------------------------------------------------------------
%
% outBoundary1 resp. outBoundary2 are 2xN matrices containing the x and y
% coordinates of the inner- resp. outer-boundary. 
%
% outMask1 and outMask2 are logical matrices with the same size as the
% background figure used during the selection. These output arguments can
% be omitted. 


function varargout = conObjBound_D(varargin)

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

myMask1 = myMask;
myBound1 = bwboundaries(myMask1);
if length(myBound1) == 0
    myError(nargout);
    return;
end

myBound1 = myBound1{1};
if length(myBound1) == 0
    myError(nargout);
    return;
end
myBound1 = fliplr(myBound1)';
hold on
plot(myBound1(1,:), myBound1(2,:),'w');


myMask = [];
while isempty(myMask)
    if isvalid(myFigure)
        myMask = roipoly;
    else
        break;
    end
end

myMask2 = myMask;
myBound2 = bwboundaries(myMask2);
if length(myBound2) == 0
    myError(nargout);
    return;
end

myBound2 = myBound2{1};
if length(myBound2) == 0
    myError(nargout);
    return;
end
myBound2 = fliplr(myBound2)';
hold on
plot(myBound2(1,:), myBound2(2,:),'w');
myClims = get(gca,'CLim');


myMask1_test = roipoly(myImage, myBound1(1,:), myBound1(2,:));
myMask2_test = roipoly(myImage, myBound2(1,:), myBound2(2,:));

if sum(myMask1_test(:)) < sum(myMask2_test(:))
    temp = myBound1;
    myBound1 = myBound2;
    myBound2 = temp;
    
    temp = myMask1;
    myMask1 = myMask2;
    myMask2 = temp;
end


myMask_test = not(myMask1).*myMask2;
if sum(myMask_test(:)) > 0
    myError(nargout);
    return;
end

[myX myY] = conObjGetTwoPix;

if (sum(abs(myX(:))== 0)) || (sum(abs(myX(:))== 0))
    myError(nargout);
    return;
end

myDist1 = (myBound1(1,:)-myY(1)).^2+(myBound1(2,:)-myX(1)).^2;
myDist2 = (myBound2(1,:)-myY(2)).^2+(myBound2(2,:)-myX(2)).^2;

[myMin1 myIndex1] = min(myDist1);
[myMin2 myIndex2] = min(myDist2);


myBound1 = horzcat(myBound1(:, myIndex1:end), myBound1(:, 2:myIndex1));
myBound2 = horzcat(myBound2(:, myIndex2:end), myBound2(:, 2:myIndex2));

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
varargout{3} = myMask1;
varargout{4} = myMask2;

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


