function out = conObjCheckDir(argDir, dlgFlag)

    if nargin < 2
        dlgFlag = 1; 
    end
    
    out = 1; 
    
    if isnumeric(argDir)
        out = 0; 
        return; 
    end
    
    if not(exist(argDir,'dir')==7)
        out = 0;
        if dlgFlag
            errordlg('Directory does not exist'); 
        end
    end
end
