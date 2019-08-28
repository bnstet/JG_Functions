% Denoise Movies

X = read_file('/experiment/TwoPhoton/Rinberg_example_cleaned/Rinberg_example_cleaned/JG10982_171121_field3_stim_00002_00001.tif',1);
[X1,X2] = deinterleave(X);
data_size = numel(X1);
% reshape(X1(1,1,:),[1 250])
X1_vec = reshape(X1,numel(X1(:,:,1)),size(X1,3));
tic
[Xdn, sigma, npars, u, vals, v] = MP(double(X1_vec),20);
toc
X1_dn = reshape(Xdn,size(X1,1),size(X1,2),size(X1,3));
X1_m = [];
X1_m(:,:,:) = X1_dn-32768;
implay(X1_m)

% 
% m = immovie(X1_m,colormap('gray'));
% M2 = uint16(M2);
% saveastiff(M2,fullfile(pwd,'aligned',[name(1:end-4) '_aligned.tif']));
% % for j = 1:size(X1,3)
% for i = 1:numel(X1(:,:,1))
%     X1_vec(i,j) = X1(i)