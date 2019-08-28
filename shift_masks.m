function [] = shift_masks(sourcef, targetf, sourceMaskDir, outMaskDir)

%% Load source template, target templates, and source masks


mfiles = dir([sourceMaskDir '*.bmp']);
nMasks = length(mfiles);

source = read_file(sourcef);
if length(size(source)) >   2
    source = source(:,:,1);
end
target = read_file(targetf);
if length(size(target)) > 2
    target = target(:,:,1);
end

srcMasks = zeros( [size(source) nMasks]);
for i=1:nMasks
   mf = mfiles(i);
   srcMasks(:,:,i) = imread(fullfile(mf.folder,mf.name));
end
%% get shifts

options_nonrigid = NoRMCorreSetParms('d1',size(target,1),'d2',size(target,2),...
    'grid_size',[32,32],'mot_uf',4,'bin_width',50,'max_shift',15,...
    'max_dev',3,'us_fac',50);
tic;

%[M2,shifts2,template2] = normcorre_batch(targetStack,options_nonrigid,source);
%tmpTarget = repmat(targetStack(:,:,i),1,1,nMasks);
[~,shiftOut] = normcorre(target,options_nonrigid,source);

toc


%% Apply shifts to masks

outMasks = zeros(size(srcMasks));
tic;

for mInd=1:nMasks
    outMasks(:,:,mInd) = apply_shifts(srcMasks(:,:,mInd), shiftOut, options_nonrigid, 0,0,0,.01);
end

mmax = max(max(srcMasks)); % src mask maxima
outMasks = (outMasks > (.5 * mmax )) .* mmax; % threshold to half mask value to handle interpolation
toc
%% Save output masks
mkdir(outMaskDir);
for mInd=1:nMasks
    mf = mfiles(mInd);
    imwrite(outMasks(:,:,mInd), fullfile(outMaskDir,mf.name))
end

disp(['Registered masks written to output directory ' outMaskDir])

end