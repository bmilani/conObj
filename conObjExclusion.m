% Bastien Milani, September 2016, CHUV Lausanne
%
% This class allows the manual selection of some polygons on a background
% image of grey-levels. The inner-mask of these polygons are then stored
% after the selection. These masks can be manipulated with different
% control functions and displayed in a figure. In particular, the
% intersection of all these masks with a list of masks returned by the
% function conObjMask can be computed. 
%
% The function 'look' displays the size of the masks as well as the number
% of masks stored in the object. 
%
% The function 'stack' allows to add a mask to the object. 
%
% The function 'show' displays all the mask together. (Use the option 'each'
% to display them each in a different figure). 
%
% The function 'remove' allows to remove one of the masks. (Give the 
% number of the mask to remove as argument). 
%
% The function 'clear' put the object in its initial state. 
%
% The function 'crop', with a list of masks returned by conObjMask as
% argument, returns a new list ok masks multiplied point wise with the
% negative of each mask of the object. 


classdef conObjExclusion < handle
    
    % private variables (all variables are private)------------------------
    properties(GetAccess = 'private', SetAccess = 'private')
        
        imageSize;
        imageSizeFlag;
        
        maskArray;
        boundCell;
        numOfMasks;
    end
    
    %public functions------------------------------------------------------
    methods
        % constructor(s)---------------------------------------------------
        function obj = conObjExclusion(varargin)
            
            obj.imageSize = [];
            obj.imageSizeFlag = false; 
            
            obj.maskArray = [];
            obj.boundCell = [];
            obj.numOfMasks = 0;
            
            myRefresh(obj);
        end
        
        % get-set-functions------------------------------------------------
        
        function out = getImageSize(obj)
            out = obj.imageSize;
        end
        
        function out = getMaskArray(obj)
            out = obj.maskArray;
        end
        
        function out = getBoundCell(obj)
            out = obj.boundCell;
        end
        
        function out = getnumOfMasks(obj)
            out = obj.numOfMasks;
        end
        
        function out = getExclusion(obj)
            out = not(logical(sum(obj.maskArray,3)));
        end
                
        % control-functions------------------------------------------------
        
        function look(obj)
           if isempty(obj.imageSize)
              disp('Image size : empty');
           else
               disp(['Image size : ', num2str(obj.imageSize)]); 
           end
           
           if obj.numOfMasks == 0
              disp('Number of masks : 0');
           else
               disp(['Number of masks : ', num2str(obj.numOfMasks)]); 
           end
           
        end
        
        
        
        function stack(obj, argIm)
            if nargin ==1
                errordlg('Wrong argument !')
                return;
            end
             
            if obj.numOfMasks > 0
                if not(isequal(size(argIm(:,:,1)), obj.imageSize))
                    errordlg(   ['The input image',...
                                ' does not have the correct size !']);
                    return;
                end
            end
            
            myFig = conObjImage(argIm, 'figId');
            
            hold on
            for i =1:obj.numOfMasks
                myBound = obj.boundCell{i};
                plot(myBound(2,:), myBound(1,:),'g')
            end
            hold off
            
            myMask = [];
            while isempty(myMask)
                if isvalid(myFig)
                    myMask = roipoly;
                else
                    break;
                end
            end
            delete(myFig);
            if isempty(myMask)
                myRefresh(obj);
                return;
            end
            obj.maskArray = cat(3, obj.maskArray,myMask);
            myBound = bwboundaries(myMask);
            myBound{1} = myBound{1}';
            obj.boundCell = [obj.boundCell myBound];
            if obj.numOfMasks == 0
                obj.imageSize = size(argIm(:,:,1)); 
                obj.imageSizeFlag = true;
            end
            myRefresh(obj);
        end
        
        function clear(obj)
            obj.maskArray = [];
            obj.boundCell = [];
            obj.imageSize = [];
            obj.numOfMasks = 0;
            obj.imageSizeFlag = false; 
            myRefresh(obj);
        end
        
        function remove(obj, varargin)
            if obj.numOfMasks == 0
                return;
            end
            
            if isempty(varargin)
                argInt = obj.numOfMasks;
            else
                argInt = varargin{1};
            end
            
            if (argInt < 1) || (argInt > obj.getnumOfMasks)
                errordlg('Wrong argument !');
                return;
            end
            
            obj.maskArray(:,:,argInt) = [];
            obj.boundCell(argInt) = [];
            myRefresh(obj);
        end
        
        
        function show(obj, argIm, varargin)
            if isempty(varargin)
                size(argIm)
                conObjImage(argIm);
                hold on
                for i =1:obj.numOfMasks
                    myBound = obj.boundCell{i};
                    plot(myBound(2,:), myBound(1,:),'g')
                end
                hold off
            end
            
            if length(varargin) == 1
                if isnumeric(varargin{1})
                    conObjImage(argIm);
                    myInt = varargin{1};
                    myBound = obj.boundCell{myInt};
                    hold on
                    plot(myBound(2,:), myBound(1,:),'g')
                    hold off
                elseif strcmp(varargin{1}, 'each')
                    for i =1:obj.numOfMasks
                        conObjImage(argIm);
                        title(['Mask number : ' num2str(i)]);
                        myBound = obj.boundCell{i};
                        hold on
                        plot(myBound(2,:), myBound(1,:),'g')
                        hold off
                    end
                end
            end
            myRefresh(obj);
        end
       
        function out = crop(obj, argConObjMask)
            
            myLength = size(argConObjMask, 3); 
            myExclusion = not(logical(sum(obj.maskArray,3)));
            myExclusion = repmat(myExclusion, [1 1 myLength]); 
            out = logical(argConObjMask.*myExclusion); 
            
            myRefresh(obj); 
        end
        
    end
    
    % proivate functions---------------------------------------------------
    methods(Access = 'private')
        
        function myRefresh(obj)
            
            obj.numOfMasks = size(obj.maskArray,3);
            if isempty(obj.maskArray)
                obj.numOfMasks = 0;
                obj.boundCell = [];
                obj.maskArray = [];
                 
                obj.imageSize = []; 
                obj.imageSizeFlag = false; 
                
            end
        end
        
    end
end

