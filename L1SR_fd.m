function [hIm, ww] = L1SR_fd(lIm, zooming, patch_size, overlap, Dh, Dl, lambda, regres,nu)
% Use sparse representation as the prior for image super-resolution
% Usage
%       [hIm] = L1SR_fd(lIm, zooming, patch_size, overlap, Dh, Dl, lambda)
% 
% Inputs
%   -lIm:           low resolution input image, single channel, e.g.
%   illuminance
%   -zooming:       zooming factor, e.g. 3
%   -patch_size:    patch size for the low resolution image
%   -overlap:       overlap among patches, e.g. 1
%   -Dh:            dictionary for the high resolution patches
%   -Dl:            dictionary for the low resolution patches
%   -regres:       'L1' use the sparse representation directly to high
%                   resolution dictionary;
%                   'L2' use the supports found by sparse representation
%                   and apply least square regression coefficients to high
%                   resolution dictionary.
% Ouputs
%   -hIm:           the recovered image, single channel
%
% Written by Jianchao Yang @ IFP UIUC
% April, 2009
% Webpage: http://www.ifp.illinois.edu/~jyang29/
% For any questions, please email me by jyang29@uiuc.edu
%
% Reference
% Jianchao Yang, John Wright, Thomas Huang and Yi Ma. Image superresolution
% as sparse representation of raw image patches. IEEE Computer Society
% Conference on Computer Vision and Pattern Recognition (CVPR), 2008. 
%

% M.Amintoosi, Adding Fractional Differential ...

[lhg, lwd] = size(lIm);
hhg = lhg*zooming;
hwd = lwd*zooming;

mIm = imresize(lIm, 2,'bicubic');
[mhg, mwd] = size(mIm);
hpatch_size = patch_size*zooming;
mpatch_size = patch_size*2;
%
fdf1 = fdf(nu);
mIm = imfilter(mIm,fdf1);
% extract gradient feature from lIm
hf1 = [-1,0,1];
vf1 = [-1,0,1]';
hf2 = [1,0,-2,0,1];
vf2 = [1,0,-2,0,1]';

lImG11 = conv2(mIm,hf1,'same');
lImG12 = conv2(mIm,vf1,'same');
lImG21 = conv2(mIm,hf2,'same');
lImG22 = conv2(mIm,vf2,'same');
% 
% figure(1);
% subplot(221), imshow(lImG11);
% subplot(222), imshow(lImG12);
% subplot(223), imshow(lImG21);
% subplot(224), imshow(lImG22);
% 
lImfea(:,:,1) = lImG11;
lImfea(:,:,2) = lImG12;
lImfea(:,:,3) = lImG21;
lImfea(:,:,4) = lImG22;

% h = fspecial('average',3);
% sIm = imfilter(mIm,h); % smoothed Image
% 
% fdf1 = fdf(0.5);
% LimFDF1 = imfilter(mIm,fdf1);
% LimFDF1 = LimFDF1 - sIm;
% lImfea(:,:,5) = LimFDF1;
% 
% fdf2 = fdf(0.9);
% LimFDF2 = imfilter(mIm,fdf2);
% LimFDF2 = LimFDF2 - sIm;
% lImfea(:,:,6) = LimFDF2;
% figure(1);
% subplot(221), imshow(LimFDF1);


lgridx = 2:patch_size-overlap:lwd-patch_size;
lgridx = [lgridx, lwd-patch_size];
lgridy = 2:patch_size-overlap:lhg-patch_size;
lgridy = [lgridy, lhg-patch_size];

mgridx = (lgridx - 1)*2 + 1;
mgridy = (lgridy - 1)*2 + 1;

% using linear programming to find sparse solution
bhIm = imresize(lIm, zooming, 'bicubic');
hIm = zeros([hhg, hwd]);
nrml_mat = zeros([hhg, hwd]);

hgridx = (lgridx-1)*zooming + 1;
hgridy = (lgridy-1)*zooming + 1;

disp('Processing the patches sequentially...');
count = 0;

totalPoints = length(mgridx)*length(mgridy);
% loop to recover each patch
for xx = 1:length(mgridx),
    for yy = 1:length(mgridy),
        
        mcolx = mgridx(xx);
        mrowy = mgridy(yy);
        
        count = count + 1;
%         if ~mod(count, 100)
%             fprintf('.\n');
%         else
%             fprintf('.');
%         end
        if mod(count,round(.1*totalPoints)) == 0
            fprintf('%d%%-',round(count/totalPoints*100))
        end
        
        mpatch = mIm(mrowy:mrowy+mpatch_size-1, mcolx:mcolx+mpatch_size-1);
        mmean = mean(mpatch(:));
        
        mpatchfea = lImfea(mrowy:mrowy+mpatch_size-1, mcolx:mcolx+mpatch_size-1, :);
        mpatchfea = mpatchfea(:);
        
        mnorm = sqrt(sum(mpatchfea.^2));
        
        if mnorm > 1,
            y = mpatchfea./mnorm;
        else
            y = mpatchfea;
        end;
        
%         w = SolveLasso(Dl, y, size(Dl, 2), 'nnlasso', [], lambda);
        w = feature_sign(Dl, y, lambda);
        
        if isempty(w),
            w = zeros(size(Dl, 2), 1);
        end;
        switch regres,
            case 'L1'
                if mnorm > 1,
                    hpatch = Dh*w*mnorm;
                else
                    hpatch = Dh*w;
                end;
            case 'L2'
                idx = find(w);
                lsups = Dl(:, idx);
                hsups = Dh(:, idx);
                w = inv(lsups'*lsups)*lsups'*mpatchfea;
                hpatch = hsups*w;
            otherwise
                error('Unknown fitting!');
        end;
      
        hpatch = reshape(hpatch, [hpatch_size, hpatch_size]);
        hpatch = hpatch + mmean;
        
        hcolx = hgridx(xx);
        hrowy = hgridy(yy);
        
        hIm(hrowy:hrowy+hpatch_size-1, hcolx:hcolx+hpatch_size-1)...
            = hIm(hrowy:hrowy+hpatch_size-1, hcolx:hcolx+hpatch_size-1) + hpatch;
        nrml_mat(hrowy:hrowy+hpatch_size-1, hcolx:hcolx+hpatch_size-1)...
            = nrml_mat(hrowy:hrowy+hpatch_size-1, hcolx:hcolx+hpatch_size-1) + 1;
    end;
end;

fprintf('done!\n');

% fill the empty
hIm(1:zooming, :) = bhIm(1:zooming, :);
hIm(:, 1:zooming) = bhIm(:, 1:zooming);


hIm(end-zooming+1:end, :) = bhIm(end-zooming+1:end, :); 
hIm(:, end-zooming+1:end) = bhIm(:, end-zooming+1:end);

% % % for Z=2
% % hIm(end, :) = bhIm(end, :); 
% % hIm(:, end) = bhIm(:, end);

nrml_mat(nrml_mat < 1) = 1;
hIm = hIm./nrml_mat;
hIm = uint8(hIm);

