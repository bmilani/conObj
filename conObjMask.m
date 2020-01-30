% Bastien Milani, September 2016, CHUV Lausanne
%
% This function computes a list of logical masks as described by the
% concentric-object technique. 
%
%Usage : 
%--------------------------------------------------------------------------
% outMaskList = conObjMask(argImage,
%                          argBoundary1,
%                          argBoundary2, 
%                          n); 
%--------------------------------------------------------------------------
% outMaskList = conObjMask(argImage,
%                          argBoundary1,
%                          argBoundary2, 
%                          n, 
%                          'image'); 
%--------------------------------------------------------------------------
% 
% The second usage is similar to the first one but displays in addition the 
% output in a figure at the end of the process. 
%
% argImage must be an image with the same size as the one used for the
% selection of the inner- and outer-boundary. 
%
% argBoundary1 and argBoundary2 are the 2XN matrices that are
% returned by the functions conObjBound_C and/or conObjBound_D and describe
% the inner- resp. outer- boundaries. 
%
% n is the desired number of masks to be computed.
%
% outMaskList is an array of dimension 3. Each 2-dimensional array
% outMaskList(:,:,i) for i = 1, ... , n is a logical mask with the same 
% size as argImage. Each mask describes a layer of the concentric-object
% technique. 


function varargout = conObjMask(argImage, argBound1, argBound2, n, varargin)

returnFlag = false;
if nargin < 4
    returnFlag = true;
end

if size(argImage, 1) < 2 || size(argImage, 2) < 2
    returnFlag = true;
end

if n < 1
    returnFlag = true;
end

if ndims(argBound1) > 2 || ndims(argBound2) > 2
    returnFlag = true;
end

if not(size(argBound1, 1) == 2 || size(argBound1, 2) == 2)
    returnFlag = true;
end

if not(size(argBound2, 1) == 2 || size(argBound2, 2) == 2)
    returnFlag = true;
end

if returnFlag
    varargout{1} = 0;
    errordlg('Wrong list of arguments');
    return;
end

if size(argBound1, 2) == 2
   argBound1 = argBound1'; 
end

if size(argBound2, 2) == 2
   argBound2 = argBound2'; 
end

imageFlag = false;
if length(varargin)>0
    if strcmp(varargin{1}, 'image')
        imageFlag = true;
    end
end

argImage = argImage(:,:,1);

myBound1 = argBound1;
myBound2 = argBound2;
myLength1 = size(myBound1,2);
myLength2 = size(myBound2,2);

myBound = horzcat(myBound1(:,1:end-1), myBound2(:,end-1:-1:1));
myMask = roipoly(argImage, myBound(1,:), myBound(2,:));

myMask1 = roipoly(argImage, myBound1(1,:), myBound1(2,:));
myMask2 = roipoly(argImage, myBound2(1,:), myBound2(2,:));

if sum(myMask(:)) == 0
    varargout{1} = 0;
    errordlg('Wrong list of arguments');
    return;
end

if ( sum(myMask1(:)) == 0 || sum(myMask2(:)) == 0)
    varargout{1} = 0;
    errordlg('Wrong list of arguments');
    return;
end

myCOMask    = zeros(size(myMask,1),size(myMask,2),n);
myCONet     = zeros(myLength1,2,n);

for i = 1:myLength1
    myIndex = max(1,round(myLength2 * i/myLength1));
    for k = 1:n
        myCONet(i,:,k) = (myBound2(:,myIndex)+k*(myBound1(:,i)-myBound2(:,myIndex))/n)';
    end
end

for k = 1:n
    myPoly = vertcat(myCONet(:,:,k),myBound2(:,end:-1:1)');
    myCOMask(:,:,k) = roipoly(argImage, myPoly(:,1),myPoly(:,2));
end

for i = 1:n-1
    for j = i+1:n
        myCOMask(:,:,n-i+1) = myCOMask(:,:,n-i+1)-myCOMask(:,:,n-j+1).*myCOMask(:,:,n-i+1);
    end
end
myCOMask = flip(myCOMask, 3);

myImage = myCOMask(:,:,1);
for i = 2:n
    myImage = myImage+i*myCOMask(:,:,i);
end

if imageFlag
    figure
    imagesc(myImage)
    axis image
end

varargout{1} = logical(myCOMask);
end


