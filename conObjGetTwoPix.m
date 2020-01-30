% Bastien Milani, September 2016, CHUV Lausanne
%
% This function allows to select two pixels with the mouse directly on a
% figure. It should however not be called directly by the user. 


function [myX myY] = conObjGetTwoPix(varargin)

myFigure = gcf;
id1 = iptaddcallback(myFigure,  'WindowButtonDownFcn', @myClickCallback);
myImage = getimage(gca);


myX = [0 0];
myY = [0 0];
myCounter = 0;

uiwait
return;



    function myClickCallback(src, evnt) % nested function
        
        myCounter = mod(myCounter,2)+1;
        myCoordinates = get(gca,'CurrentPoint');
        myCoordinates = ceil(myCoordinates(1,1:2)-[0.5 0.5]);
        myX(myCounter) = myCoordinates(2);
        myY(myCounter) = myCoordinates(1);
        
        if myCounter == 1
            hold on
            plot(myY(1), myX(1), '.r')
        end
        
        if myCounter == 2
            plot(myY(2), myX(2), '.b')
            hold off
            
            iptremovecallback(myFigure,'WindowButtonDownFcn',id1);
            uiresume
            return;
            
        end
        
    end

end
