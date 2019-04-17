[sROI] = ReadImageJROI('/Users/crossxface/LocalData/ROI workspace/170120_TargetedPlusAll_v4.zip');
image = zeros(512,512);
% temp = zeros(512,512);

for j = 1:size(sROI,2)
    temp = zeros(512,512);
for i=1:length(sROI{j}.mnCoordinates)
    a(i,1:2) = sROI{j}.mnCoordinates(i,:);
    temp(a(i,1),a(i,2)) = 1;
end
    BW = roipoly(temp,a(:,1),a(:,2));
    image = image+BW;
end

figure
imagesc(image)

figure
imagesc(temp)

temp(a(i,1),a(i,2));

BW = roipoly(temp,a(:,1),a(:,2));

figure
imagesc(BW)