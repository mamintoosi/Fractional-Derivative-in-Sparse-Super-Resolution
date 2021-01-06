% function createSummaryTableDataSets(dataSets,masirOutput)
% % M.Amintoosi, HSU 2016- FUM 2019
% % Creating Tables in LaTeX
% 
% if nargin<3
    dataSets = {'BSDS100','Manga109','Set5','Set14','Urban100'};
    masirArticle = 'D:/Dropbox/Teaching/Projects/Other-Universities/Mortazavi/Article/InformationSciences2/';
    masirOutput = masirArticle;
% end
outputDir = sprintf('%s',masirOutput);

mahaks = {'MSE','PSNR','SSIM','FSIM','TT','NIQE','CEIQ'};
mahakNames = {'MSE','PSNR','SSIM','FSIM','RunTime','NIQE','CEIQ'};
mahakOptFunc = {'min','max','max','max','min','max','max'};
mahakNonOptFunc = {'max','min','min','min','max','min','min'};
mahakOptFuncSort = {'ascend','descend','descend','descend','ascend','descend','descend'};

resultsFileName = sprintf('Results_%s.mat',dataSets{1});
load(resultsFileName,'Results','methods','MSE','SSIM','FSIM','PSNR','TT','NIQE','CEIQ');

N = numel(dataSets);

% load(resultsFileName)
nMethods = length(methods);  % Discarding 1.2
% coefImW = 1/(nMethods+3);


XData = 1:N;%{Results.fileName};
for mm = 1:numel(mahaks)
    MeanData = [];
    mahak = mahaks{mm};
    
    if strcmp(mahak,'TT')
        methodsList = 3:nMethods;
    else
        methodsList = 1:nMethods;
    end
    
    mahakName = mahakNames{mm};
    
    data = zeros(N,nMethods);
    for dsNo = 1:N
        curDS = dataSets{dsNo};
        resultsFileName = sprintf('Results_%s.mat',curDS);
        load(resultsFileName,'Results','methods','MSE','SSIM','FSIM','PSNR','TT','NIQE','CEIQ');
        
        data_curDS = eval(mahak);
%         if strcmp(mahak,'TT')
%             data_curDS(:,1:2) = 1e4;
%         end
        data(dsNo,:) = mean(data_curDS);
    end
    %     data(:,end) =[]; % Discarding 1.2
    meanData = mean(data);
    %     optData = eval([mahakOptFunc{mm} '(meanData)']);
    
    %     MeanData = [MeanData; meanData];
    minData = min(data(:)); maxData = max(data(:));
    
    clmns = sprintf('DataSet');
    for m=methodsList
        clmns = [clmns sprintf(' & %5s ',methods{m})];
    end
    nCols = numel(methodsList)+1;
    
    %         plotDataFileName =  sprintf('doc%s/%s_plots/plotData_%s_%s.txt',curDS,curDS,mahaks{mm},methods{m});
    tableDataFileName =  sprintf('%s/Summary_Tbl_%s.txt',outputDir,mahaks{mm});
    [pathstr,fileName,ext] = fileparts(tableDataFileName);
    fprintf('\\input{%s%s}\n',fileName,ext)
    
    fid = fopen(tableDataFileName,'wt');
    %     fprintf(fid,'\\begin{table}\n');
    fprintf(fid,'\\begin{center}\n');
    fprintf(fid,'\\begin{longtable}{c@{\\hspace{7mm}}');
    for m=methodsList
        fprintf(fid,'c@{\\hspace{7mm}}');
    end
    fprintf(fid,'}\n');
        fprintf(fid,'\\caption{\\textbf{%s} for the proposed method $(\\nu=0.2,0.5,0.7)$ and other methods (magnified by a factor of \\textbf{3}). Each cell demonstrates the average value of the corresponding criteria for the mentioned dataset and method (row, collumn). Cells highlighted by dark and light gray, show the 1st and 2nd winners, respectively.}\n',mahakName);
    fprintf(fid,'\\label{tab:Summary:%s}\\\\\n',mahakName);
    fprintf(fid,'\\hline\n');
    
        fprintf(fid,'\\textbf{%s} & \\multicolumn{%d}{c}{Methods} \\\\',mahakName,nCols-1);
    fprintf(fid,'\\cmidrule(lr){2-%d} \n ', nCols);
    fprintf(fid,' %s \\\\ \n', clmns);
    fprintf(fid,' \\cmidrule{1-%d}\n',nCols  );
    fprintf(fid,'\\endfirsthead\n');
    fprintf(fid,'\\multicolumn{%d}{l}\n',nCols);
    fprintf(fid,'{Continue from the previous page} \\\\ \n');
    fprintf(fid,'\\hline  & \\multicolumn{%d}{c}{\\textbf{%s}} \\\\ \n',nCols-1, mahakName);
    fprintf(fid,'\\cmidrule(lr){2-%d} \n',nCols);
    fprintf(fid,' %s \\\\ \n', clmns);
    fprintf(fid,' \\cmidrule{1-%d}\n',nCols);fprintf(fid,'\\endhead\n');
    fprintf(fid,'\\hline\n');
    for m=1:numel(methodsList)-4
        fprintf(fid,'& ');
    end
    fprintf(fid,'\\multicolumn{3}{r}{Continue on the next page...}\n');
    fprintf(fid,'\\endfoot\n');
    fprintf(fid,'\\hhline{=');
    for m=methodsList
        fprintf(fid,'=');
    end
    fprintf(fid,'}\n');
    fprintf(fid,'\\endlastfoot\n');
    
    for xx=1:N
        fprintf(fid,'%s ',dataSets{xx});
        [~,sortedIdxInRow] = eval(['sort(data(xx,:),''' mahakOptFuncSort{mm} ''')']);
        for m=methodsList
            if m==sortedIdxInRow(1)
                fprintf(fid,'& \\multicolumn{1}{>{\\cellcolor[gray]{.8}}c@{\\hspace{7mm}}}{$\\mathbf{%5.3f}$} ',data(xx,m));
            elseif m==sortedIdxInRow(2)
                fprintf(fid,'& \\multicolumn{1}{>{\\cellcolor[gray]{.92}}c@{\\hspace{7mm}}}{${%5.3f}$} ',data(xx,m));
            else
                fprintf(fid,' & %6.3f ',data(xx,m));
            end
        end
        fprintf(fid,'\\\\ \n');
        %         fprintf(fid,'\n');%MeanData(xx,m));
    end
    
    fprintf(fid,'\\hhline{=');
    for m=methodsList
        fprintf(fid,'=');
    end
    fprintf(fid,'}\n');
    fprintf(fid,'Avg');
    [~,sortedIdxInRow] = eval(['sort(meanData,''' mahakOptFuncSort{mm} ''')']);
    for m=methodsList
        if m==sortedIdxInRow(1)
            fprintf(fid,'& \\multicolumn{1}{>{\\cellcolor[gray]{.8}}c@{\\hspace{7mm}}}{$\\mathbf{%5.3f}$} ',meanData(m));
        elseif m==sortedIdxInRow(2)
            fprintf(fid,'& \\multicolumn{1}{>{\\cellcolor[gray]{.92}}c@{\\hspace{7mm}}}{${%5.3f}$} ',meanData(m));
        else
            fprintf(fid,'& $%5.3f$ ',meanData(m));
        end
    end
    fprintf(fid,'\\\\ \n');
    
    fprintf(fid,'\\hline\n');
    fprintf(fid,'\\end{longtable} \n');
    fprintf(fid,'\\end{center}\n');
    %     fprintf(fid,'\\end{table}\n');
    fclose(fid);
end
