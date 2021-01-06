% M.Amintoosi

%  Results
clear
masir = 'D:/Data/SR_testing_datasets/';
masirDics = 'D:/Dropbox2019/Teaching/Projects/Other-Universities/Mortazavi/Code/CVPR08-SR/Data/Dics/';
dataSets = {'BSDS100','Manga109','Set5','Set14','Urban100'};
%masirArticle = 'D:/Dropbox2019/Teaching/Projects/Other-Universities/Mortazavi/Article/InformationSciences/';
masirArticle = 'D:/Dropbox/Teaching/Projects/Other-Universities/Mortazavi/Article/InformationSciences2/';
masirOutput = [masirArticle 'output/'];

% masirRes = 'D:/Dropbox/Teaching/Projects/Other-Universities/Mortazavi/Article/InformationSciences/HMQuad/Code-Information-Sciences/';

N_dataSets = numel(dataSets);
ns_dataSets = [100,109,5,14,100];

for dsNo = 1:N_dataSets
    curDS = dataSets{dsNo};
    
    resultsFileName = sprintf('Results_%s.mat',dataSets{dsNo});
    load(resultsFileName,'Results');%,'TT');%,'methods','MSE','SSIM','FSIM','PSNR','TT');
%    createLatexImageTables(curDS,masirArticle,5)
%     createPlotsData(curDS,masirArticle)
     createTableData(curDS,masirOutput)
end
% createSummaryTableDataSets