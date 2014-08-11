function[room3Ds,Ks,Rs,camera_heights] = computeLayouts_Hedau(imagename,vps,f,h,w,img, weightY, weightP, weightA)
global camera_ht;
%%This function loads box results of hedau et al and uses that to obtain
%%room estimates.
filename=fullfile('../dataset/hedauOutput/',[imagename(1:end-4) '_layres.mat']);

resultDirectory = ['results' num2str(weightY) '_' num2str(weightP) '_' num2str(weightA) '/'];

mkdir(resultDirectory);
mkdir([resultDirectory imagename(1:end-4)]);

load(filename);
vv=lay_scores(:,1);
ii=lay_scores(:,2);

for lay=1:min(numel(ii),1)
    layoutid=ii(lay);
    Polyg=[];
    for fie=1:5
        Polyg{fie}=[];
        if size(polyg{layoutid,fie})>0
            Polyg{fie}=polyg{layoutid,fie};
        end
    end
    tempimg=displayout(Polyg,w,h,img);
%    imwrite(uint8(tempimg), [resultDirectory imagename(1:end-4) '/old' num2str(lay, '%02d') '.jpg']);

    tempimg2=displayblank(Polyg,w,h);
%    imwrite(uint8(tempimg2), [resultDirectory imagename(1:end-4) '/oldLabels' num2str(lay, '%02d') '.jpg']);

    dlmwrite([resultDirectory imagename(1:end-4) '/old' num2str(lay, '%02d') 'Score.txt'], [vv(lay)], ' ');
    dlmwrite([resultDirectory imagename(1:end-4) '/old' num2str(lay, '%02d') 'Ind.txt'], [ii(lay)], ' ');
    savePolygon([resultDirectory  imagename(1:end-4) '/old' num2str(lay, '%02d') 'Labels.txt'], Polyg);
end

%Load the heatmaps
standHeatmap = loadAndScaleHeatmap(fullfile('../dataset/heatmapsHighRecallFancy/',[imagename '.standHeat.mat']), size(img));
sitHeatmap = loadAndScaleHeatmap(fullfile('../dataset/heatmapsHighRecallFancy/',[imagename '.sitHeat.mat']), size(img));
sitFeetHeatmap = loadAndScaleHeatmap(fullfile('../dataset/heatmapsHighRecallFancy/',[imagename '.sitfeetHeat.mat']),size(img));

standPedroHeatmap = loadAndScaleHeatmap(fullfile('../dataset/heatmapsPedro2/',[imagename '.standHeat.mat']), size(img));
sitPedroHeatmap = loadAndScaleHeatmap(fullfile('../dataset/heatmapsPedro2/',[imagename '.sitHeat.mat']), size(img));
sitFeetPedroHeatmap = loadAndScaleHeatmap(fullfile('../dataset/heatmapsPedro2/',[imagename '.sitfeetHeat.mat']),size(img));
    

%approximate relative floor areas
v0 = getHorizonLine(vps(f));
[~, Y] = meshgrid(1:size(img,2), 1:size(img,1));
%multiply everything through by a reasonable number so that the values aren't tiny (and thus hard to read)
D = 500 .* (1./ (Y - v0));
%we don't want points above the horizon line to give negative values
D = abs(D);
D = min(D, quantile(D(:), 0.8));
gridDistance = diff(D);
%make it the correct size by replicating the first row
gridDistance = [gridDistance(1,:); gridDistance];
gridArea = gridDistance .^ 2;

n = numel(ii);
maxScore = max(vv); minScore = min(vv); 
polygonScores = zeros(n, 1);
for i=1:n
    polygonScores(ii(i)) = vv(i);
end
[penalties, areas] = filterHedauPolygons(polyg, standHeatmap+sitFeetHeatmap, ii, gridArea);
fprintf('Second penalty!\n');
[penaltiesP, areasP] = filterHedauPolygons(polyg, standPedroHeatmap+sitFeetPedroHeatmap, ii, gridArea);
%    penalties = 0.5 .* penalties + 0.5 .* penaltiesP;

scoreRange = dlmread(['../dataset/vhRanges/' imagename(1:end-4) '.txt']);
fprintf('Score range: %f\n', scoreRange);

penalties = (penalties .* scoreRange);
penaltiesP = (penaltiesP .* scoreRange);
polygonScores = polygonScores - weightY*penalties - weightP*penaltiesP;
vv_old = vv;
ii_old = ii;
[vv, ii] = sort(polygonScores, 'descend');
fprintf('Reordering!\n');
fprintf('Old best hypothesis: %d\n', ii_old(1));
fprintf('New best hypothesis (pre-area): %d\n', ii(1));


%take the top n hypotheses
scoreSortedAreas = areas(ii);
minAreaRequired = min(scoreSortedAreas(1:3));
%do another round of penalties, based on the area
areaPenalty = max(0.0, areas - minAreaRequired);
polygonScores = polygonScores - (weightA * scoreRange) .* (min(1.0, areaPenalty ./ minAreaRequired));
vv_preAreas = vv;
ii_preAreas = ii;
[vv, ii] = sort(polygonScores, 'descend');
fprintf('Reordering!\n');
fprintf('Next best hypothesis (post-area): %d\n', ii(1));  


figure(102);
drawnow;
for lay=1:min(numel(ii), 1)
    layoutid=ii(lay);
    Polyg=[];
    for fie=1:5
        Polyg{fie}=[];
        if size(polyg{layoutid,fie})>0
            Polyg{fie}=polyg{layoutid,fie};
        end
    end
    tempimg=displayout(Polyg,w,h,img);
%    imwrite(uint8(tempimg), [resultDirectory imagename(1:end-4) '/new' num2str(lay,'%02d') '.jpg']);

    tempimg2=displayblank(Polyg,w,h);
%    imwrite(uint8(tempimg2), [resultDirectory imagename(1:end-4) '/newLabels' num2str(lay, '%02d') '.jpg']);

    dlmwrite([resultDirectory imagename(1:end-4) '/new' num2str(lay, '%02d') 'Score.txt'], [vv(lay)], ' ');
    dlmwrite([resultDirectory imagename(1:end-4) '/new' num2str(lay, '%02d') 'Ind.txt'], [ii(lay)], ' ');
    savePolygon([resultDirectory imagename(1:end-4) '/new' num2str(lay, '%02d') 'Labels.txt'], Polyg);    
end


room3Ds = {};
Ks = {};
Rs = {};
cam_heights = {};
for roomHyp=1:1
    fprintf('Room Hyp = %d\n', roomHyp);
    layoutid=ii(roomHyp);
    for fie=1:5
        Polyg{fie}=[];
        if size(polyg{layoutid,fie})>0
            Polyg{fie}=polyg{layoutid,fie};
        end
    end

%    ShowGTPolyg(img,Polyg,2);

    vp = vps(f);
    V = zeros(2,3);
    [V(1,1) V(2,1)] = img_to_norm_img(vp.vp(1,1),vp.vp(1,2),size(img,2),size(img,1));
    [V(1,2) V(2,2)] = img_to_norm_img(vp.vp(2,1),vp.vp(2,2),size(img,2),size(img,1));
    [V(1,3) V(2,3)] = img_to_norm_img(vp.vp(3,1),vp.vp(3,2),size(img,2),size(img,1));
    
    [A ind] = max(abs(V(2,:)));
    if ind ~= 1
        temp = V(:,ind);
        V(:,ind) = V(:,1);
        V(:,1) = temp;
    end

    %%Using Vanishing Points Estimate Camera Calibration
    [K R]=calibrate_camera_fast(V);
    

    camera_ht = 5;
    [room3D1,K,R] = compute3DRoom_V(Polyg,V,h,w,img,K,R);
    [room3D2] = compute3DRoom_V1(Polyg,K,R,img,room3D1.maxY);
    room3D = room3D2;

    roomHypsSoFar = numel(room3Ds)+1;
    room3Ds{roomHypsSoFar} = room3D;
    Ks{roomHypsSoFar} = K;
    Rs{roomHypsSoFar} = R;
    camera_heights{roomHypsSoFar} = camera_ht;
end
