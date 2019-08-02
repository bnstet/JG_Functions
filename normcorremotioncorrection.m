function normcorremotioncorrection(name,tempname)

addpath('/home/jvg219/NoRMCorre-master/')
% name = ['/experiment/TwoPhoton/2P_Detection/JG8432/170120/Template/' name];
% tempname = '/experiment/TwoPhoton/2P_Detection/JG8432/170120/Template/green/Template_green.tif';

tic; Y = read_file(name); toc; % read the file (optional, you can also pass the path in the function instead of Y)
Y = double(Y);      % convert to double precision 
T = size(Y,ndims(Y));
template = read_file(tempname);

options_nonrigid = NoRMCorreSetParms('d1',size(Y,1),'d2',size(Y,2),...
    'grid_size',[32,32],'mot_uf',4,'bin_width',50,'max_shift',15,...
    'max_dev',3,'us_fac',50);
tic; 
[M2,shifts2,template2] = normcorre_batch(Y,options_nonrigid,template); 
toc
saveastiff(M2,[pwd '/aligned/' name-4 '_aligned.tif']);