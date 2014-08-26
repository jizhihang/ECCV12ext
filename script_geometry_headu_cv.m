if ~exist('result_image/')
    mkdir('result_image/');
end

if ~exist('results/');
    mkdir('results/');
end

addpath('util');
addpath('util/code_3rd');

set(0,'defaultFigureVisible','off');

%%Image Directories
imdir='../dataset/images/';
%d=dir([imdir '*.jpg']);

%%Load Precomputed Vanishing points
load ../dataset/Allvpdata.mat
%%Load Precomputed Segmentations
load ../dataset/imsegs.mat

%%Mapping of names between Hedau et al. and Lee et al.
map = name_mapping();

global camera_ht;
global DEBUG_DISPLAY;
%Show Debug Outputs
DEBUG_DISPLAY = 0;

%this is for synchronizing results
if ~exist('../locksDump/');
    mkdir('../locksDump/');
end

lockDirectory = ['../locksDump/'];

if ~exist(lockDirectory)
    mkdir(lockDirectory);
end

fParam = fopen('paramFolder.txt');
paramNames = textscan(fParam,'%s');
fclose(fParam);

paramValues = dlmread('paramValue.txt');

%%Run for each of test images
for f=1:size(map{1},1)
    %%Assume camera height to be 5feet.
    camera_ht = 5;

    skip = 1;
    %%Dataset image number 
    %%Get File Name for corresponding image
    fn = strtok(map{2}(f),'.');

    %figure out which parameters to use from the saved c-v file
    paramLoc = find(strcmp(paramNames{1},fn));
    %if it crashed before, don't run it again.
    if numel(paramLoc) == 0
        continue; 
    end

    weightY = paramValues(paramLoc,1);
    weightP = paramValues(paramLoc,2);
    weightA = paramValues(paramLoc,3);

    paramValues(paramLoc,:)

    if ~exist(fullfile('../dataset/heatmapsPedro2/',[fn{1} '.jpg.standHeat.mat']))
        continue;
    end
  
    lockBase = [lockDirectory '/' fn{1}];

    if exist([lockBase '.done']) || isLocked([lockBase '.lock'])
        continue;
    end

    disp(['Processing --' fn{1}]);
    
    fprintf(fn{1});
    
    %%ImageName in Hedau et al.
    %imagename=d(imgnum).name;
    imagename = [fn{1} '.jpg'];
    %%Read Image
    img=imread([imdir imagename]);    
    [h w imk]=size(img);
    
    %Load Hedau et al for room layout and calibrating camera
    %
    % This finds the best layout given the structure prediction evidence + the affordance vidence
    %
    try
        [room3Ds,Ks,Rs,camera_heights] = computeLayouts_Hedau(imagename,Allvpdata,f,h,w,img, weightY, weightP, weightA);
    catch
        fprintf('Something crashed in computing Hedau layouts\n');
       continue;
    end
    numRooms = numel(room3Ds);

    %don't bother filling the room.
    continue;

    for roomHyp = 1:1%1
        room3D = room3Ds{roomHyp}; K = Ks{roomHyp}; R = Rs{roomHyp};
        oldroom3D = room3D;
        camera_ht = camera_heights{roomHyp};

        imgnum = f;
        try
            [room3D] = doInverseVoxelFillTL(imagename,imgnum,room3D,K,R,imsegs, img);
        catch
            continue
        end
        oldcamera_ht = camera_ht;

        %%Final Result Display
        project_room_with_walls(room3D, img, K, R,camera_ht);
        saveas(gca,['./result_image/' fn{1} '_result' num2str(roomHyp) '.jpg']);
    end

    mkdir([lockBase '.done']);
    unlock([lockBase '.lock']);
end


bestI = 40;

weightY = weights(weightYI(bestI)); 
weightP = weights(weightPI(bestI));
weightA = areaWeights(weightAI(bestI));
resultDirectory = ['results/'];

n = size(map{1}, 1);
old = cell(n, 1);
new = cell(n, 1);
for i = 1 : n        
    filename=fullfile(resultDirectory, map{1}{i}, 'new01Labels.txt');
    if exist(filename, 'file')       
        new{i} = readPoly(filename);
    end   
    
    filename=fullfile(resultDirectory, map{1}{i}, 'old01Labels.txt');
    if exist(filename, 'file')    
        old{i} = readPoly(filename);
    end 
end

aold = evalScore(map, old)
anew = evalScore(map, new)

