% Image super-resolution using sparse representation
% Example code
%
% Nov. 2, 2007. Jianchao Yang
% IFP @ UIUC
%
% Revised version. April, 2009.

% Modified by M.Amintoosi, FUM 2021
% clear all;
clc;

addpath('Solver');
addpath('Sparse coding');
addpath('vifvec_release');
addpath('sepspyr')
% =====================================================================
% specify the parameter settings

patch_size = 3; % patch size for the low resolution input image
overlap = 1; % overlap between adjacent patches
lambda = 0.1; % sparsity parameter
zooming = 5; % zooming factor, if you change this, the dictionary needs to be retrained.

tr_dir = 'Data/training'; % path for training images
skip_smp_training = true; % sample training patches
skip_dictionary_training = true; % train the coupled dictionary
num_patch = 50000; % number of patches to sample as the dictionary
codebook_size = 1024; % size of the dictionary

regres = 'L1'; % 'L1' or 'L2', use the sparse representation directly, or use the supports for L2 regression
% =====================================================================
% training coupled dictionaries for super-resolution

if ~skip_smp_training,
    disp('Sampling image patches...');
    [Xh, Xl] = rnd_smp_dictionary(tr_dir, patch_size, zooming, num_patch);
    save('Data/Dictionary/smp_patches.mat', 'Xh', 'Xl');
    skip_dictionary_training = false;
end;

if ~skip_dictionary_training,
    load('Data/Dictionary/smp_patches.mat');
    [Dh, Dl] = coupled_dic_train(Xh, Xl, codebook_size, lambda);
    save('Data/Dictionary/Dictionary.mat', 'Dh', 'Dl');
else
    load('Data/Dictionary/Dictionary.mat');
end;

% =====================================================================
% Process test images
% "masir" is transliteration of Persian translation of "path"

masir = '/Data/Test/'; % Path to dataset folder
masirDics = 'Data/Dictionary/'; % Path to dictionaries folder
dataSets = {'BSDS100','Manga109','Set5','Set14','Urban100'};%,'Set2MAT'};
masirArticle = 'Article/';  % Path to Article, where the output files will be stored
masirOutput = [masirArticle 'output_x' num2str(zooming) '_p3/'];

methods = {'LR','BC','ID','FD-.2'};%,'FD-.5','FD-.7'};%,'FD-1.2'};%,'FD-1.5'};
% NN: Nearest Neighbor
% BC: Bicubic,
% ID: Integer Deferential
% FD: Fractional Deferential

K=[.01 .03];
W=fspecial('gaussian', 5, 1.5);%5,1.5

nMethods = numel(methods);
markers = {'b-','c-','r:o','g-.p','m--s','k:<','y:>'};

N_dataSets = numel(dataSets);
%%
for dsNo = 1:N_dataSets
    curDS = dataSets{dsNo};
    
%     resultsFileName = sprintf('Results_%s.mat',dataSets{dsNo});
%     load(resultsFileName,'Results','methods','MSE','SSIM','FSIM','PSNR','TT');
    clear Results MSE SSIM FSIM PSNR TT 
    
    masirTestImages = sprintf('%s/%s/',masir,curDS);
    % fileList=dir([masir 'tt*.*']);
    fileList=dir([masirTestImages '*.png']);
    % fileList(1:2) = []; % Removing '.' and '..'
    for ii=1 :  numel(fileList)
        sprintf('Processing Image %d of %d ...',ii,numel(fileList))
        fileName = fileList(ii).name(1:end-4)
        outputDir = sprintf('%s/%s/%s',masirOutput,curDS,fileName);
        mkdir(outputDir);
        outputDir = [outputDir '/'];
        fname = [masirTestImages fileList(ii).name];
        testIm = imread(fname); % testIm is a high resolution image, we downsample it and do super-resolution
        Results(ii).fileName = fileName;
        
        if rem(size(testIm,1),zooming) ~=0
            nrow = floor(size(testIm,1)/zooming)*zooming;
            testIm = testIm(1:nrow,:,:);
        end
        if rem(size(testIm,2),zooming) ~=0
            ncol = floor(size(testIm,2)/zooming)*zooming;
            testIm = testIm(:,1:ncol,:);
        end
        
        
        %     imwrite(testIm, [outputDir 'high.bmp'], 'BMP');
        imwrite(testIm, [outputDir 'high.jpg'], 'JPG');
        
        lowIm = imresize(testIm,1/zooming, 'bicubic');
        %     imwrite(lowIm,[outputDir 'low.bmp'],'BMP');
        
        bcIm = imresize(lowIm,zooming,'bicubic');
        imwrite(uint8(bcIm),[outputDir 'bc.jpg'],'JPG');
        
        imSize = size(bcIm);
        nChannels = 1;
        if numel(imSize)==3
            nChannels = 3;
        end
            
        isColor = nChannels == 3;
        % work with the illuminance domain only
        if isColor
            lowIm2 = rgb2ycbcr(lowIm);
        else
            lowIm2 = lowIm;
        end
        lImy = double(lowIm2(:,:,1));
        
        % bicubic interpolation for the other two channels
        if isColor
            interpIm2 = rgb2ycbcr(bcIm);
            hImcb = interpIm2(:,:,2);
            hImcr = interpIm2(:,:,3);
        end
        % ======================================================================
        % Super-resolution using sparse representation
        for methodNo = 3:nMethods
            methodName = methods{methodNo}
            fprintf('Start superresolution - %S ...\n',methodName)
            tic;
            switch methodName
                case 'ID'
%                     load([masirDics 'Dictionary_ID_Iter15.mat']);
                    dicFileName = sprintf('%s/Dictionary_ID_x%d_p%d.mat', masirDics,zooming,patch_size);
                    load(dicFileName);
                    [hImy] = L1SR(lImy, zooming, patch_size, overlap, Dh, Dl, lambda, regres);
                case 'FD-.2'
                    nu = .2;
%                     load([masirDics 'Dictionary_FD.2_Iter15.mat']);
                    dicFileName = sprintf('%s/Dictionary_FD.%d_iter15_x%d_p%d.mat',masirDics, nu*10,zooming,patch_size);
                    load(dicFileName);
                    [hImy] = L1SR_fd(lImy, zooming, patch_size, overlap, Dh, Dl, lambda, regres,nu);
                case 'FD-.5'
                    nu = .5;
                    load([masirDics 'Dictionary_FD.5_Iter15.mat']);
                    [hImy] = L1SR_fd(lImy, zooming, patch_size, overlap, Dh, Dl, lambda, regres,nu);
                case 'FD-.7'
                    nu = .7;
                    load([masirDics 'Dictionary_FD.7_Iter15.mat']);
                    [hImy] = L1SR_fd(lImy, zooming, patch_size, overlap, Dh, Dl, lambda, regres,nu);
                case 'FD-1.2'
                    nu = .12;
                    load([masirDics 'Dictionary_FD1.2_Iter15.mat']);
                    [hImy] = L1SR_fd(lImy, zooming, patch_size, overlap, Dh, Dl, lambda, regres,nu);
                case 'FD-1.5'
                    nu = 1.5;
                    load([masirDics 'Dictionary_FD1.5_Iter15.mat']);
                    [hImy] = L1SR_fd(lImy, zooming, patch_size, overlap, Dh, Dl, lambda, regres,nu);
            end
            
            runTime = toc;
            ReconIm = uint8(zeros(imSize(1),imSize(2),nChannels));
            ReconIm(:,:,1) = uint8(hImy);
            if isColor
                ReconIm(:,:,2) = hImcb;
                ReconIm(:,:,3) = hImcr;
                ReconIm = ycbcr2rgb(ReconIm);
            end
            %         figure(1),clf, imshow(ReconIm,[]);
            title(methodName);
            outputFileName = [outputDir methodName '_rec.png'];
            imwrite(uint8(ReconIm),outputFileName,'PNG');
            outputFileName = [outputDir methodName '_rec.jpg'];
            imwrite(uint8(ReconIm),outputFileName,'JPG');
            Results(ii).method(methodNo).outputFileName = outputFileName;
            border = floor(size(testIm,1)*.05);
            [h,w,~] = size(testIm);
            testImCrop = testIm(border:h-border,border:w-border,:);
            ReconImCrop = ReconIm(border:h-border,border:w-border,:);
                        
            Results(ii).method(methodNo).rmse = compute_rmse(testImCrop, ReconImCrop);
            %         Results(ii).method(methodNo).rmse = compute_rmse(testIm, ReconIm);
%             Results(ii).method(methodNo).psnr = 20*log10(255/Results(ii).method(methodNo).rmse);
            Results(ii).method(methodNo).psnr = psnr(ReconImCrop,testImCrop);
            Results(ii).method(methodNo).mse = immse(ReconImCrop,testImCrop);
            Results(ii).method(methodNo).runTime = runTime;
%             Results(ii).method(methodNo).ssim = ssim_index(im2uint8(testImCrop),im2uint8(ReconImCrop),K,W);
            Results(ii).method(methodNo).ssim = ssim(ReconImCrop,testImCrop);
            Results(ii).method(methodNo).fsim = FeatureSIM(im2uint8(testImCrop),im2uint8(ReconImCrop));
            
        end
        nnIm = imresize(lowIm, zooming, 'nearest');
        imwrite(uint8(nnIm),[outputDir 'nn.JPG'],'JPG');
        
        %     figure, imshow(nnIm);
        %     title('Input image');
        %     % pause(1);
        %     figure, imshow(bcIm);
        %     title('Bicubic interpolation');
        % pause(1)
        % compute PSNR for the illuminance channel
        nn_rmse = compute_rmse(testIm, nnIm);
        bc_rmse = compute_rmse(testIm, bcIm);

        nn_mse = immse(nnIm,testIm);
        bc_mse = immse(bcIm,testIm);
        
        nn_psnr = psnr(nnIm,testIm);%20*log10(255/nn_rmse);
        bc_psnr = psnr(bcIm,testIm);%20*log10(255/bc_rmse);
        
        nn_ssim = ssim(nnIm,testIm);%ssim_index(im2uint8(testIm),im2uint8(nnIm),K,W);
        bc_ssim = ssim(bcIm,testIm);%ssim_index(im2uint8(testIm),im2uint8(bcIm),K,W);
        
        nn_fsim = FeatureSIM(im2uint8(testIm),im2uint8(nnIm));
        bc_fsim = FeatureSIM(im2uint8(testIm),im2uint8(bcIm));
        
        Results(ii).method(1).outputFileName = [outputDir 'nn.jpg'];
        Results(ii).method(1).rmse = nn_rmse;
        Results(ii).method(1).mse  = nn_mse;
        Results(ii).method(1).psnr = nn_psnr;
        Results(ii).method(1).ssim = nn_ssim;
        Results(ii).method(1).fsim = nn_fsim;
        Results(ii).method(1).runTime = 1e5;
        
        Results(ii).method(2).outputFileName = [outputDir 'bc.jpg'];
        Results(ii).method(2).rmse = bc_rmse;
        Results(ii).method(2).mse  = bc_mse;
        Results(ii).method(2).psnr = bc_psnr;
        Results(ii).method(2).ssim = bc_ssim;
        Results(ii).method(2).fsim = bc_fsim;
        Results(ii).method(2).runTime = 1e5;
    end
    
    %%
    % load('Results_SSR_01.mat');
    N = numel(Results);
    % for ii=1:N
    %     Results(ii).method(1).runTime = 0;
    %     Results(ii).method(2).runTime = 0;
    %     Results(ii).method(1).ssim = 0;
    %     Results(ii).method(2).ssim = 0;
    % end
    nMethods = numel(methods);
    MSE = zeros(N,nMethods);
    PSNR = MSE;
    SSIM = MSE;
    TT = MSE;
    FSIM = MSE;
    RMSE = MSE;
%     VIF = MSE;
    for ii=1:numel(Results)
        for j=1:nMethods, RMSE(ii,j)=Results(ii).method(j).rmse; end
        for j=1:nMethods, MSE(ii,j)=Results(ii).method(j).mse; end
        for j=1:nMethods, PSNR(ii,j)=Results(ii).method(j).psnr; end
        for j=1:nMethods, SSIM(ii,j)=Results(ii).method(j).ssim; end
        for j=1:nMethods, FSIM(ii,j)=Results(ii).method(j).fsim; end
        for j=1:nMethods, TT(ii,j)= Results(ii).method(j).runTime; end
    end
    %%
    figure(11), clf, hold on
    for j=1:nMethods
        plot(1:N,MSE(:,j),markers{j});
    end
    
    legend(methods);
    tstr = mat_printf('MSE (Avg): ',methods,mean(MSE));
    title(tstr)
    hold off
    print('-dpng',gcf,'doc/mse.png');
    
    figure(12), clf, hold on
    for j=1:nMethods
        plot(1:N,SSIM(:,j),markers{j});
    end
    legend(methods);
    tstr = mat_printf('SSIM (Avg): ',methods,mean(SSIM));
    title(tstr)
    hold off
    print('-dpng',gcf,'doc/ssim.png');
    
    figure(13), clf, hold on
    for j=1:nMethods
        plot(1:N,PSNR(:,j),markers{j});
    end
    legend(methods);
    tstr = mat_printf('PSNR (Avg): ',methods,mean(PSNR));
    title(tstr)
    hold off
    print('-dpng',gcf,'doc/psnr.png');
    % figure(13), plot(TT);   legend({'MP','BN','BNSWZ'})
    sprintf('%3d   ',1:nMethods)
    methods
    sprintf('%5.3f ',mean(MSE))
    sprintf('%5.3f ',mean(SSIM))
    sprintf('%5.3f ',mean(PSNR))
    sprintf('%5.3f ',mean(FSIM))
    %%
%     % resultsFileName = sprintf('Results_SSR_500px4.mat');
    resultsFileName = sprintf('Results_%s_x%d_p5.mat',curDS,zooming);
    save(resultsFileName,'Results','methods','MSE','SSIM','PSNR','TT','FSIM');
    % %%
%     createLatexImageTables(resultsFileName,curDS,masirOutput)
%     createPlotsData(curDS,masirArticle)
%     createTableData(curDS,masirOutput)
end %end for datasets
zooming
% createSummaryTableDataSets