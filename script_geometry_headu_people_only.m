%%Set Paths
addpath('util');
addpath('util/code_3rd');

lockDirectory = '../locks/';

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

%weights = [0.125, 0.25, 0.5, 0.75, 1.0, 1.5, 2, 4, 8];
weights = [1.0 / 16, 0.125, 0.25, 0.5, 1.0, 2];
areaWeights = [3, 10, 25];

[weightYI,weightPI] = meshgrid(1:numel(weights),1:numel(weights));
weightYI = weightYI(:); weightPI = weightPI(:);
%ugly ugly ugly but whatever
weightAI = [repmat(1,numel(weightYI),1); repmat(2,numel(weightYI),1); repmat(3,numel(weightYI),1)];
weightYI = repmat(weightYI,numel(areaWeights),1);
weightPI = repmat(weightPI,numel(areaWeights),1);


for weightI=1:numel(weightYI)

weightY = weights(weightYI(weightI)); weightP = weights(weightPI(weightI));
weightA = areaWeights(weightAI(weightI));

if weightAI(weightI) == 1
    continue;
end

if ~exist('../locks/');
    mkdir('../locks/');
end

lockDirectory = ['../locks/' num2str(weightY) '_' num2str(weightP) '_' num2str(weightA) '/'];

if ~exist(lockDirectory)
    mkdir(lockDirectory);
end

%%Run for each of 105 test images
for f=1:size(map{1},1)
    %%Assume camera height to be 5feet.
    camera_ht = 5;

    skip = 1;
    %%Dataset image number 
    %%Get File Name for corresponding image
    fn = strtok(map{2}(f),'.');

    if ~exist(fullfile('../dataset/heatmapsPedro/',[fn{1} '.jpg.standHeat.mat']))
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
    try
        [room3Ds,Ks,Rs,camera_heights] = computeLayouts_Hedau(imagename,Allvpdata,f,h,w,img, weightY, weightP, weightA);
    % [room3D,Ks,Rs] = computeLayouts_Hedau(imagename,Allvpdata,imgnum,h,w,img);
    catch
        fprintf('Something crashed in computing Hedau layouts\n');
       continue;
    end
    numRooms = numel(room3Ds);

    for roomHyp = 1:0%1
        room3D = room3Ds{roomHyp}; K = Ks{roomHyp}; R = Rs{roomHyp};
        %%%%%Hypothesis 1
        %%%%%
        %%Given the room estimates project clutter mask back into 3D and slide
        %%Cuboids to Obtain Hypothesis One
        oldroom3D = room3D;
        camera_ht = camera_heights{roomHyp};

        project_room_with_walls(room3D, img, K, R,camera_ht);
        
        saveas(gca,['./result_image/' fn{1} '_beforeBlocks' num2str(roomHyp) '.jpg']);
        close all;
        
        try
            [room3D] = doInverseVoxelFillTL(imagename,imgnum,room3D,K,R,imsegs, img);
        catch
            continue
        end
        oldcamera_ht = camera_ht;

        %%Final Result Display
        project_room_with_walls(room3D, img, K, R,camera_ht);
        saveas(gca,['./result_image/' fn{1} '_result' num2str(roomHyp) '.jpg']);
        %close all;
    end

    mkdir([lockBase '.done']);
    unlock([lockBase '.lock']);
end
end    
