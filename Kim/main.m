% Modified by M.Amintoosi, 2022
clear
% close all

nu = 0.8;
methods = {'BC','ID',sprintf('FD-%3.1f',nu)};
dataSets = {'Set5','Set14'};%,'BSDS100','Manga109','Urban100'};
N_dataSets = numel(dataSets);
nMethods = numel(methods);
markers = {'b-','c-','r:o','g-.p','m--s','k:<','y:>'};

[h,hximp,hyimp] = fdf(nu);
output_path = 'output';
%%
RESULTS = {};
for dsNo = 1:N_dataSets
    ds = dataSets{dsNo};
    clear Results MSE SSIM FSIM PSNR TT
    mkdir(sprintf('%s/%3.1f/%s',output_path,nu,ds));
    myFolder = sprintf('../Data/Test/%s/',ds);
    myFiles = dir(fullfile(myFolder,'*.png'));
    for ii = 1:length(myFiles)
%         if ii>3, break, end
        baseFileName = myFiles(ii).name;
        Results(ii).fileName = baseFileName;
        fullFileName = fullfile(myFolder, baseFileName);
        HR_img = imread(fullFileName);
        Ori_img_Color = HR_img;
        if numel(HR_img)==3
            HR_img = rgb2ycbcr(HR_img);
        end
        if strcmp(ds,'Mangn109')==0 || strcmp(ds,'Urban100')==0
            HR_img = imresize(HR_img,0.5);
        end
        
        Pad=2;
        Scale=2;
        
        HR_img = HR_img(:,:,1);
        HR_size = size(HR_img(:,:,1));
        
        % adjusting Image size
        Adj_HR_size = ceil(HR_size/Scale)*Scale;
        Adj_HR_size = [Adj_HR_size,1];
        Adj_HR_img = zeros(Adj_HR_size);
        Adj_HR_img(1:HR_size(1),1:HR_size(2),:) = HR_img;
        
        for i = HR_size(1):Adj_HR_size(1)
            Adj_HR_img(i,1:HR_size(2),:) = HR_img(end,:,:);
        end
        for i = HR_size(2):Adj_HR_size(2)
            Adj_HR_img(:,i,:) = Adj_HR_img(:,HR_size(2),:);
        end
        
        HR_img = double(Adj_HR_img);
        %         subplot(141), imshow(uint8(HR_img)), title('HR image')
        LR_img = imresize(HR_img,0.5);
        %         subplot(142), imshow(uint8(LR_img))
        Bicubic_img= imresize(LR_img,2, 'bicubic');
        bc_mse = immse(Bicubic_img,HR_img);
        bc_psnr = psnr(Bicubic_img,HR_img,255);
        bc_ssim = ssim(Bicubic_img,HR_img);
        bc_fsim = FeatureSIM((HR_img),(Bicubic_img));
        Results(ii).method(1).mse  = bc_mse;
        Results(ii).method(1).psnr = bc_psnr;
        Results(ii).method(1).ssim = bc_ssim;
        Results(ii).method(1).fsim = bc_fsim;
        %         title(['Bicubic, PSNR=',num2str(PSNR_Bic)])
        
        for methodNo = 2:3
            Degree=2;
            
            LR_img = imresize(HR_img,0.5);
            
            if methodNo==2
                Feed_img=LR_img;
            elseif methodNo==3 % Fractional Derivative
                Feed_img = imfilter(LR_img,h);
            end
            
            % gradient operaotr
            hdx = [1,-1];
            hdy = [1;-1];
            hdx2 = [2,-1;-1,0];
            hdy2 = [-1,0;2,-1];
            
            % Threshold
            Thr1=25;
            Thr2=25;
            
            % main
            for i=1:3
                Out_D = class_IMG(Thr1,Pad,Scale,Degree,LR_img,Feed_img,hdx,hdy);
                Out_img = test_IMG(Thr1,Pad,Scale,Degree,LR_img,Out_D,hdx,hdy);
                
                Out_D2 = class_IMG(Thr2,Pad,Scale,Degree,LR_img,Feed_img,hdx2,hdy2);
                Out_img2 = test_IMG(Thr2,Pad,Scale,Degree,LR_img,Out_D2,hdx2,hdy2);
                
                Feed_img= (Out_img2 + Out_img)/2;
                
                Degree=Degree+2;
            end
            Results(ii).method(methodNo).mse = immse(Feed_img,HR_img);
            Results(ii).method(methodNo).psnr = psnr(Feed_img,HR_img,255);
            Results(ii).method(methodNo).ssim = ssim(Feed_img,HR_img); 
            Results(ii).method(methodNo).fsim = FeatureSIM((HR_img),(Feed_img));
        end
    end
    
    N = numel(Results);
    nMethods = numel(methods);
    MSE = zeros(N,nMethods);
    PSNR = MSE;
    SSIM = MSE;
    FSIM = MSE;
    

    for ii=1:numel(Results)
        for j=1:nMethods, MSE(ii,j)=Results(ii).method(j).mse; end
        for j=1:nMethods, PSNR(ii,j)=Results(ii).method(j).psnr; end
        for j=1:nMethods, SSIM(ii,j)=Results(ii).method(j).ssim; end
        for j=1:nMethods, FSIM(ii,j)=Results(ii).method(j).fsim; end
    end
    %%
    figure(12), clf, hold on
    for j=1:nMethods
        plot(1:N,SSIM(:,j),markers{j});
    end
    legend(methods);
    tstr = mat_printf('SSIM (Avg): ',methods,mean(SSIM));
    title(tstr)
    hold off
    output_file_name = sprintf('%s/%3.1f/%s/ssim.png',output_path,nu,ds);
    print('-dpng',gcf,output_file_name);
    
    figure(13), clf, hold on
    for j=1:nMethods
        plot(1:N,PSNR(:,j),markers{j});
    end
    legend(methods);
    tstr = mat_printf('PSNR (Avg): ',methods,mean(PSNR));
    title(tstr)
    hold off
    output_file_name = sprintf('%s/%3.1f/%s/psnr.png',output_path,nu,ds);
    print('-dpng',gcf,output_file_name);

%     sprintf('%5.3f ',mean(SSIM))
%     sprintf('%5.3f ',mean(PSNR))
    RESULTS{dsNo}.Results = Results;
    RESULTS{dsNo}.MSE = MSE;
    RESULTS{dsNo}.PSNR = PSNR;
    RESULTS{dsNo}.SSIM = SSIM;
    RESULTS{dsNo}.FSIM = FSIM;
end
%%
disp(['MSE  ' sprintf('%8s  ',methods{:})])
for i=1:numel(RESULTS)
    disp([sprintf('%9s',dataSets{i}) sprintf(' %7.4f ',mean(RESULTS{i}.MSE))])
end

disp(['PSNR   ' sprintf('%7s  ',methods{:})])
for i=1:numel(RESULTS)
    disp([sprintf('%9s',dataSets{i}) sprintf(' %6.4f ',mean(RESULTS{i}.PSNR))])
end

disp(['SSIM ' sprintf('%7s  ',methods{:})])
for i=1:numel(RESULTS)
    disp([sprintf('%9s',dataSets{i}) sprintf(' %5.6f ',mean(RESULTS{i}.SSIM))])
end

disp(['FSSIM' sprintf('%7s  ',methods{:})])
for i=1:numel(RESULTS)
    disp([sprintf('%9s',dataSets{i}) sprintf(' %5.6f ',mean(RESULTS{i}.FSIM))])
end
%%
resultsFileName = sprintf('%s/%3.1f/RESULTS.mat',output_path,nu);
save(resultsFileName,'RESULTS');
    