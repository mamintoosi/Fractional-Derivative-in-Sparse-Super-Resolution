% Image super-resolution using sparse representation
% Example code
%
% Nov. 2, 2007. Jianchao Yang
% IFP @ UIUC
%
% Revised version. April, 2009.
%
% Reference
% Jianchao Yang, John Wright, Thomas Huang and Yi Ma. Image superresolution
% via sparse representation of raw image patches. IEEE Computer Society
% Conference on Computer Vision and Pattern Recognition (CVPR), 2008. 
%
% For any questions, email me by jyang29@illinois.edu

clear all;
clc;
tic
addpath('Solver');
addpath('Sparse coding');

% =====================================================================
% specify the parameter settings

patch_size = 3; % patch size for the low resolution input image
overlap = 1; % overlap between adjacent patches
lambda = 0.1; % sparsity parameter
zooming = 5; % zooming factor, if you change this, the dictionary needs to be retrained.
nu = .2;
tr_dir = 'Data/training'; % path for training images
skip_smp_training = false;  %true;%true; %sample training patches
skip_dictionary_training = true; %false;  %true; % false; %train the coupled dictionary
num_patch = 50000;%50000; % number of patches to sample as the dictionary
codebook_size = 1024;%1024; % size of the dictionary

regres = 'L1'; % 'L1' or 'L2', use the sparse representation directly, or use the supports for L2 regression
% =====================================================================
% training coupled dictionaries for super-resolution
% 
smp_patches_fileName = sprintf('Data/Dictionary/smp_patches_.%d_x%d_p%d.mat',nu*10,zooming,patch_size);
dicFileName = sprintf('Data/Dictionary/Dictionary_FD.%d_iter15_x%d_p%d.mat', nu*10,zooming,patch_size);
if ~skip_smp_training,
    disp('Sampling image patches...');
    [Xh, Xl] = rnd_smp_dictionary_fd(tr_dir, patch_size, zooming, num_patch,nu);
    save(smp_patches_fileName, 'Xh', 'Xl');
    skip_dictionary_training = false;
end;

if ~skip_dictionary_training,
    load(smp_patches_fileName);
    [Dh, Dl] = coupled_dic_train(Xh, Xl, codebook_size, lambda);
    save(dicFileName, 'Dh', 'Dl');
else
    load(dicFileName);
end;

% =====================================================================
%% Process the test image 
fileName ='1.bmp';% 'tt3.bmp';%'204.jpg';%'baboon.png'; %
fname = sprintf('Data/Test/%s',fileName);
testIm = imread(fname); % testIm is a high resolution image, we downsample it and do super-resolution

if rem(size(testIm,1),zooming) ~=0,
    nrow = floor(size(testIm,1)/zooming)*zooming;
    testIm = testIm(1:nrow,:,:);
end;
if rem(size(testIm,2),zooming) ~=0,
    ncol = floor(size(testIm,2)/zooming)*zooming;
    testIm = testIm(:,1:ncol,:);
end;

imwrite(testIm, sprintf('output/%s_high.bmp',fileName), 'BMP');

lowIm = imresize(testIm,1/zooming, 'bicubic');
imwrite(lowIm,sprintf('output/%s_low.bmp',fileName), 'BMP');

interpIm = imresize(lowIm,zooming,'bicubic');
imwrite(uint8(interpIm),sprintf('output/%s_bb.bmp',fileName), 'BMP');

% work with the illuminance domain only
lowIm2 = rgb2ycbcr(lowIm);
lImy = double(lowIm2(:,:,1));

% bicubic interpolation for the other two channels
interpIm2 = rgb2ycbcr(interpIm);
hImcb = interpIm2(:,:,2);
hImcr = interpIm2(:,:,3);

% ======================================================================
% Super-resolution using sparse representation

disp('Start superresolution...');

[hImy] = L1SR_fd(lImy, zooming, patch_size, overlap, Dh, Dl, lambda, regres,nu);

ReconIm(:,:,1) = uint8(hImy);
ReconIm(:,:,2) = hImcb;
ReconIm(:,:,3) = hImcr;

nnIm = imresize(lowIm, zooming, 'nearest');
figure(1), imshow(nnIm);
title('Input image');
pause(1);
figure(2), imshow(interpIm);
title('Bicubic interpolation');
pause(1)

ReconIm = ycbcr2rgb(ReconIm);
figure(3),imshow(ReconIm,[]);
title('Our method');
imwrite(uint8(ReconIm),sprintf('output/%s_SRfd_z2.bmp',fileName))
%%
psnrNNIm = psnr(nnIm,testIm);
psnrBIm = psnr(interpIm,testIm);
psnrSRIm = psnr(ReconIm,testIm);
sprintf('PSNR FDF NN=%f, Bicubic=%f, SR=%f', psnrNNIm, psnrBIm,psnrSRIm)
toc
save('Data/Resluts_fdf_z2','psnr*')