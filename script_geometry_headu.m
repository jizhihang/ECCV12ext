if ~exist('result_image/')
    mkdir('result_image/');
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%These were for doing CV of the weights; 
%basically it was done via leave-one-out, 
%so results were pre-computed for each setting
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
weights = [1.0 / 16, 0.125, 0.25, 0.5, 1.0, 2];
areaWeights = [0, 0.125, 0.25];

[weightYI,weightPI] = meshgrid(1:numel(weights),1:numel(weights));
weightYI = weightYI(:); weightPI = weightPI(:);
%ugly ugly ugly but whatever
weightAI = [repmat(1,numel(weightYI),1); 
            repmat(2,numel(weightYI),1); 
            repmat(3,numel(weightYI),1)];
weightYI = repmat(weightYI,numel(areaWeights),1);
weightPI = repmat(weightPI,numel(areaWeights),1);

%40 seems to produce ok results 
for weightI=40 %1:numel(weightYI)

weightY = weights(weightYI(weightI)); 
weightP = weights(weightPI(weightI));
weightA = areaWeights(weightAI(weightI));

%this is for synchronizing results
if ~exist('../locks/');
    mkdir('../locks/');
end

lockDirectory = ['../locksDump/' num2str(weightY) '_' num2str(weightP) '_' num2str(weightA) '/'];

if ~exist(lockDirectory)
    mkdir(lockDirectory);
end

%%Run for each of test images
for f=1:size(map{1},1)
    %%Assume camera height to be 5feet.
    camera_ht = 5;

    skip = 1;
    %%Dataset image number 
    %%Get File Name for corresponding image
    fn = strtok(map{2}(f),'.');

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
end    

bestI = 40;

weightY = weights(weightYI(bestI)); 
weightP = weights(weightPI(bestI));
weightA = areaWeights(weightAI(bestI));
resultDirectory = ['results' num2str(weightY) '_' num2str(weightP) '_' num2str(weightA) '/'];

n = size(map{1}, 1);
old = cell(n, 1);
new = cell(n, 1);
for i = 1 : n    
    filename=fullfile('../dataset/hedauOutput/',[map{1}{i} '_layres.mat']);
    load(filename, 'polyg');
    
    filename=fullfile(resultDirectory, map{1}{i}, 'new01Ind.txt');
    if ~exist(filename, 'file')
        new{i} = cell(1, 5);
    else 
        ii = load(filename);
        new{i} = polyg(ii, :);
    end   
    
    filename=fullfile(resultDirectory, map{1}{i}, 'old01Ind.txt');
    if ~exist(filename, 'file')
        old{i} = cell(1, 5);
    else 
        ii = load(filename);
        old{i} = polyg(ii, :);
    end 
end

aold = evalScore(map, old)
anew = evalScore(map, new)