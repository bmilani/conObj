function out = conObjDirNameList(argDir)

    if not(conObjCheckDir(argDir)) return; end; 
    
    myList = dir(argDir); 
    myList = myList(3:end);
    
    out = cell(length(myList),1); 
    for i = 1:length(myList)
        out{i} = myList(i).name; 
    end
    

end
