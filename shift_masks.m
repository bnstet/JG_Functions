function [] = shift_masks(sourcef, targetf, sourceMaskDir, outMaskDir)

%% Load source template, target templates, and source masks


mfiles = dir(fullfile(sourceMaskDir, '*.bmp'));
nMasks = length(mfiles);

source = read_file(sourcef);
source = log(double(source(:,:,1))+1);  

target = read_file(targetf);
target = log(double(target(:,:,1))+1);

srcMasks = zeros( [size(source) nMasks]);
for i=1:nMasks
   mf = mfiles(i);
   srcMasks(:,:,i) = imread(fullfile(mf.folder,mf.name));
end

mmax = max(max(srcMasks)); % src mask maxima
%% get shifts


options_nonrigid = NoRMCorreSetParms('d1',size(target,1),'d2',size(target,2),...
    'grid_size',[32,32],'mot_uf',4,'bin_width',50,'max_shift',15,...
    'max_dev',3,'us_fac',50, 'shifts_method','cubic');
tic;

%[M2,shifts2,template2] = normcorre_batch(targetStack,options_nonrigid,source);
%tmpTarget = repmat(targetStack(:,:,i),1,1,nMasks);
[M_final,shifts,template,options,col_shift] = normcorre(source,options_nonrigid,target);

toc


%% Apply shifts to masks

outMasks = zeros(size(srcMasks));
tic;

for mInd=1:nMasks
    outMasks(:,:,mInd) = apply_shifts(srcMasks(:,:,mInd), shifts, options_nonrigid,'col_shift',col_shift);
end

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