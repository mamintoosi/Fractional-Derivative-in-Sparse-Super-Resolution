% M.Amintoosi

% Merge Results
clear
masir = 'D:/Data/SR_testing_datasets/';
masirDics = 'D:/Dropbox/Teaching/Projects/Other-Universities/Mortazavi/Code/CVPR08-SR/Data/Dics/';
dataSets = {'BSDS100','Manga109','Set5','Set14','Urban100'};
masirArticle = 'D:/Dropbox/Teaching/Projects/Other-Universities/Mortazavi/Article/InformationSciences/';
masirOutput = [masirArticle 'output/'];

masirRes = 'D:/Dropbox/Teaching/Projects/Other-Universities/Mortazavi/Article/InformationSciences/HMQuad/Code-Information-Sciences/';
dataSets = {'BSDS100','Manga109','Set5','Set14','Urban100'};
methods = {'LR','BC','ID','FD-.2','FD-.5','FD-.7'};%,'FD-1.2'};%,'FD-1.5'};
nMethods = numel(methods);

N_dataSets = numel(dataSets);
ns_dataSets = [100,109,5,14,100];

for dsNo = 1:N_dataSets-1
    curDS = dataSets{dsNo};
    
    clear Results MSE SSIM FSIM PSNR TT
    
    resultsFileName = sprintf('Results_%s.mat',dataSets{dsNo});
    hp = load(resultsFileName,'Results');%,'TT');%,'methods','MSE','SSIM','FSIM','PSNR','TT');
%     TT_HP = TT;
%     Results_HP = Results;
    
    resultsFileNameHMQuad = [masirRes resultsFileName];
    hmquad = load(resultsFileNameHMQuad);
    
%     Results(ns_dataSets(dsNo)+1:end) = [];
    
    N = ns_dataSets(dsNo);% numel(Results);
    
    for ii=1:N
        Results(ii) = hmquad.Results(ii);
        for m=1:nMethods
            Results(ii).method(m).runTime = hp.Results(ii).method(m).runTime;
        end
        Results(ii).method(1).runTime = 1e4;
        Results(ii).method(2).runTime = 1e4;
    end
    %     [TT TT_HP]
    %     TT = TT_HP;
    %     TT(:,1:2) = 1e5;
%     N = numel(Results);
    
    nMethods = numel(methods);
    MSE = zeros(N,nMethods);
    PSNR = MSE;
    SSIM = MSE;
    TT = MSE;
    FSIM = MSE;
    for ii=1:numel(Results)
        for j=1:nMethods, MSE(ii,j)=Results(ii).method(j).rmse; end
        for j=1:nMethods, PSNR(ii,j)=Results(ii).method(j).psnr; end
        for j=1:nMethods, SSIM(ii,j)=Results(ii).method(j).ssim; end
        for j=1:nMethods, FSIM(ii,j)=Results(ii).method(j).fsim; end
        
        for j=1:nMethods, TT(ii,j)= Results(ii).method(j).runTime; end
    end
    
    resultsFileName = sprintf('Results_%s.mat',curDS);
    save(resultsFileName,'Results','methods','MSE','SSIM','PSNR','TT','FSIM');
    
    createLatexImageTables(curDS,masirOutput)
    createPlotsData(curDS,masirOutput)
    createTableData(curDS,masirOutput)
end
