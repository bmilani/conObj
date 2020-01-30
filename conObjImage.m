% Bastien Milani, September 2016, CHUV Lausanne
%
% This function allows to display a 2XN-dimensional array of grey-levels. 
% Some functionalities can be accessed from the keyboard : 
% 
% ctrl+D : to adjust the contrast. 
%
% ctrl+F : to save the contrast. 
%
% ctrl+E : to reset the contrast. 
%
% ctrl+G : to switch from black/white to a color map. 
%
% Usage : 
%
% conObjImage(argImage)
%
% where argImage is a two dimensional array of grey-levels. 


function varargout = conObjImage(argIm, varargin)

myFigure = figure(  'Name',                 'conObjImage', ...
    'keypressfcn',          @myKeyPressFunction,...
    'keyreleasefcn',        @myKeyReleaseFunction, ...
    'WindowButtonDownFcn',  @myClickCallback);

if length(varargin) > 0
    if strcmp(varargin{1}, 'figId')
        varargout{1} = myFigure;
    end
end

% Initialisation ------------------------------------------------------

wbFlag          = 1;
controlFlag     = 0;

numOfImages = size(argIm, 3); 
curImNum = 1; 
imagesc(argIm(:,:,curImNum));
axis image
colormap gray;
myClims=get(gca,'CLim');
myClimsInit = myClims;

% End of initialisation -----------------------------------------------

% The following functions are nested functions------------------------------

    function myKeyPressFunction(src,command) % nested function
        switch lower(command.Key)
            
            case 'downarrow'               
                
                curImNum = max(curImNum - 1, 1); 
                imagesc(argIm(:,:,curImNum));
                caxis(myClims);
                axis image
                
            case 'uparrow'
                
                curImNum = min(curImNum + 1, numOfImages);
                imagesc(argIm(:,:,curImNum));
                caxis(myClims);
                axis image
            
            case 'control'
                controlFlag = 1;
            case 'e'
                if controlFlag
                    myClims = myClimsInit;
                    imagesc(argIm(:,:,curImNum));
                    caxis(myClims);
                    axis image
                    controlFlag = 0;
                end
            case 'f'
                if controlFlag
                    myClims = get(gca,'CLim');
                    imagesc(argIm(:,:,curImNum));
                    caxis(myClims);
                    axis image
                    controlFlag = 0;
                end
            case 'd'
                if controlFlag
                    imcontrast(myFigure);
                    controlFlag = 0;
                end
            case 'g'
                if controlFlag
                    if wbFlag
                        colormap jet;
                        wbFlag = 0;
                    else
                        colormap gray;
                        wbFlag = 1;
                    end
                    controlFlag = 0;
                    myClims=get(gca,'CLim');
                    imagesc(argIm(:,:,curImNum));
                    caxis(myClims);
                    axis image
                end
        end
    end

    function myKeyReleaseFunction(src,command) % nested function
        if strcmp(lower(command.Key), 'control')
            controlFlag = 0;
        end
    end


end


function myClickCallback(src, evnt)
    1+1;
end

