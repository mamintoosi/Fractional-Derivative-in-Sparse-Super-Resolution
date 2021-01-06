function [Xh, Xl] = rnd_smp_dictionary_fd(tr_dir, patch_size, zooming, num_patch,nu)

fpath = fullfile(tr_dir, '*.bmp');  % MAT *-> tt1*
img_dir = dir(fpath);
Xh = [];
Xl = [];

img_num = length(img_dir);

nums = zeros(1, img_num);

for num = 1:length(img_dir),
    im = imread(fullfile(tr_dir, img_dir(num).name));
    nums(num) = prod(size(im));
end;

nums = floor(nums*num_patch/sum(nums));

for ii = 1:img_num,
    
    patch_num = nums(ii);
    im = imread(fullfile(tr_dir, img_dir(ii).name));
    
    [H, L] = sample_patches(im, patch_size, zooming, patch_num,nu);
    
    Xh = [Xh, H];
    Xl = [Xl, L];
    
    fprintf('Sampled...%d\n', size(Xh, 2));
end;

function [HP, LP] = sample_patches(im, patch_size, zooming, patch_num,nu)

lz = 2;

if size(im, 3) == 3,
    hIm = rgb2gray(im);
else
    hIm = im;
end;

if rem(size(hIm,1),zooming)
    nrow = floor(size(hIm,1)/zooming)*zooming;
    hIm = hIm(1:nrow,:);
end;
if rem(size(hIm,2),zooming)
    ncol = floor(size(hIm,2)/zooming)*zooming;
    hIm = hIm(:,1:ncol);
end;

lIm = imresize(hIm,1/zooming);
[nrow, ncol] = size(lIm);

x = randperm(nrow-patch_size-lz-1);
y = randperm(ncol-patch_size-lz-1);
[X,Y] = meshgrid(x,y);

xrow = X(:);
ycol = Y(:);

xrow = xrow(1:patch_num);
ycol = ycol(1:patch_num);

% zoom the original image
lIm = imresize(lIm, lz,'bicubic');
hIm = double(hIm);
lIm = double(lIm);

H = zeros(zooming^2*patch_size^2,patch_num);
L = zeros(lz^2*4*patch_size^2,patch_num);

%
fdf1 = fdf(nu);
lIm = imfilter(lIm,fdf1);

% compute the first and second order gradients
hf1 = [-1,0,1];
vf1 = [-1,0,1]';
 
lImG11 = conv2(lIm,hf1,'same');
lImG12 = conv2(lIm,vf1,'same');
 
hf2 = [1,0,-2,0,1];
vf2 = [1,0,-2,0,1]';
%  
lImG21 = conv2(lIm,hf2,'same');
lImG22 = conv2(lIm,vf2,'same');

% h = fspecial('average',3);
% sIm = imfilter(lIm,h); % smoothed Image
% 
% fdf1 = fdf(0.5);
% LimFDF1 = imfilter(lIm,fdf1);
% LimFDF1 = LimFDF1 - sIm;
% 
% fdf2 = fdf(0.9);
% LimFDF2 = imfilter(lIm,fdf2);
% LimFDF2 = LimFDF2 - sIm;

% fdf1 = fdf(0.5);
% LimFDF1 = imfilter(lIm,fdf1);
% % LimFDF1 = lIm - LimFDF1;
% lImG21 = LimFDF1;
% 
% fdf2 = fdf(0.9);
% LimFDF2 = imfilter(lIm,fdf2);
% % LimFDF2 = lIm - LimFDF2;
% lImG22 = LimFDF2;

count = 1;
for pnum = 1:patch_num,
    
    hrow = (xrow(pnum)-1)*zooming + 1;
    hcol = (ycol(pnum)-1)*zooming + 1;
    Hpatch = hIm(hrow:hrow+zooming*patch_size-1,hcol:hcol+zooming*patch_size-1);
    
    lrow = (xrow(pnum)-1)*lz + 1;
    lcol = (ycol(pnum)-1)*lz + 1;
    
%     fprintf('(%d, %d), %d, [%d, %d]\n', lrow, lcol, lz*patch_size,
%     size(lImG11));
    Lpatch1 = lImG11(lrow:lrow+lz*patch_size-1,lcol:lcol+lz*patch_size-1);
    Lpatch2 = lImG12(lrow:lrow+lz*patch_size-1,lcol:lcol+lz*patch_size-1);
    Lpatch3 = lImG21(lrow:lrow+lz*patch_size-1,lcol:lcol+lz*patch_size-1);
    Lpatch4 = lImG22(lrow:lrow+lz*patch_size-1,lcol:lcol+lz*patch_size-1);
%     Lpatch5FD1 = LimFDF1(lrow:lrow+lz*patch_size-1,lcol:lcol+lz*patch_size-1);
%     Lpatch6FD2 = LimFDF2(lrow:lrow+lz*patch_size-1,lcol:lcol+lz*patch_size-1);
     
    Lpatch = [Lpatch1(:),Lpatch2(:),Lpatch3(:),Lpatch4(:)];%,Lpatch5FD1(:),Lpatch6FD2(:)];
    Lpatch = Lpatch(:);
     
    HP(:,count) = Hpatch(:)-mean(Hpatch(:));
    LP(:,count) = Lpatch;
    
    count = count + 1;
    
    Hpatch = Hpatch';
    Lpatch1 = Lpatch1';
    Lpatch2 = Lpatch2';
    Lpatch3 = Lpatch3';
    Lpatch4 = Lpatch4';
%     Lpatch5FD1 = Lpatch5FD1';
%     Lpatch6FD2 = Lpatch6FD2';
    Lpatch = [Lpatch1(:),Lpatch2(:),Lpatch3(:),Lpatch4(:)];%,Lpatch5FD1(:),Lpatch6FD2(:)];
    
    HP(:,count) = Hpatch(:)-mean(Hpatch(:));
    LP(:,count) = Lpatch(:);
    count = count + 1;
    
end;


    
    