myImageList = conObjDicomRead('Dir' ,'C:\main\matlab\conObj\myGRE'); 


%%

conObjImage(myImageList)

%%
nLayers = 12; % or 12 or what you whish.  



%%

[myBound_ext, myBound_int] = conObjBound_C(myImageList); 

%%

myCO_mask = conObjMask(myImageList, myBound_ext ,myBound_int,...
                        nLayers); 

%%
conObjMaskImage(myCO_mask, 'jet'); 


%%

TE = [6:4.2:52.2]/1000; 

errorTh = 0.1;
lowerBound = 10;  
upperBound = 50;

myR2_star = conObjMonoExpFit(myImageList, TE ,errorTh, lowerBound, upperBound); 
%%
conObjImage(myR2_star); 

%%

myListOfValues = cell(1 ,nLayers); 
for i = 1:nLayers
   myListOfValues{i} = myR2_star(myCO_mask(:, :, i));
   myListOfValues{i}(isnan(myListOfValues{i})) = []; 
end

%%

myMean = zeros(1, nLayers); 
for i = 1:nLayers
   myMean(i) = mean(myListOfValues{i});  
end

%%

x = linspace(0, 100, nLayers+1);
x = x(1:end-1)+(x(2)-x(1))/2;  
plot(x, myMean ,'.-', 'Markersize', 20, 'Linewidth', 2)
set(gca, 'Fontsize', 16)
xlabel('Percent of depth')
ylabel('R_2^* (Hz)')
set(gcf, 'Color', 'w')



%%
myExclusion = conObjExclusion; 

%%
myExclusion.stack(myImageList); 
%%

myCO_mask_new = myExclusion.crop(myCO_mask); 

%%
conObjMaskImage(myCO_mask_new, 'jet')

