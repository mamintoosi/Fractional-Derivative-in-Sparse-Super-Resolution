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

mahaks = {'MSE','PSNR','SSIM','FSIM'};%,'TT','NIQE','CEIQ'};
mahakNames = {'MSE','PSNR','SSIM','FSIM','RunTime','NIQE','CEIQ'};
mahakOptFunc = {'min','max','max','max','min','max','max'};
mahakNonOptFunc = {'max','min','min','min','max','min','min'};
mahakOptFuncSort = {'ascend','descend','descend','descend','ascend','descend','descend'};

zooming = 5;
resultsFileName = sprintf('Results_%s_x%d_p3.mat',dataSets{1},zooming);
load(resultsFileName,'Results','methods','MSE','SSIM','FSIM','PSNR','TT','NIQE','CEIQ');

N = numel(dataSets);

% load(resultsFileName)
nMethods = length(methods);  % Discarding 1.2
% coefImW = 1/(nMethods+3);

methodsList = 1:nMethods
clmns = sprintf('DataSet & Eval Met. & Zooming');
for m=methodsList
    clmns = [clmns sprintf(' & %5s ',methods{m})];
end
nCols = numel(methodsList)+3;

%         plotDataFileName =  sprintf('doc%s/%s_plots/plotData_%s_%s.txt',curDS,curDS,mahaks{mm},methods{m});
tableDataFileName =  sprintf('%s/Compact_Tbl.txt',outputDir);%,mahaks{mm},zooming);
[pathstr,fileName,ext] = fileparts(tableDataFileName);
fprintf('\\input{%s%s}\n',fileName,ext)

fid = fopen(tableDataFileName,'wt');
fprintf(fid,'\\begin{table}\\scriptsize\n');
fprintf(fid,'\\vskip -0.35cm');
fprintf(fid,'\\caption{The average results of MSE, PSNR (dB), SSIM and FSSIM on the various dataset}\n');
fprintf(fid,'\\label{tab:Compact}\n');
fprintf(fid,'\\begin{center}\n');
% fprintf(fid,'\\footnotesize\n');
% fprintf(fid,'\\begin{longtable}{c@{\\hspace{7mm}}');
% for m=1:nCols-1
%     fprintf(fid,'c@{\\hspace{7mm}}');
% end
% fprintf(fid,'}\n');
fprintf(fid,'\\begin{tabular}{');
for m=1:nCols
    fprintf(fid,'c');
end
fprintf(fid,'}\n');
%         fprintf(fid,'\\caption{Results for the proposed method $(\\nu=0.2)$ and other methods. Each cell demonstrates the average value of the corresponding criteria for the mentioned dataset and method (row, collumn). Cells highlighted by dark and light gray, show the 1st and 2nd winners, respectively.}\n');
fprintf(fid,'\\hline\n');
fprintf(fid,'%s\\\\\n',clmns);
fprintf(fid,'\\hline\n');
% fprintf(fid,'\\textbf{%s} & \\multicolumn{%d}{c}{Methods} \\\\',mahakName,nCols-1);
% fprintf(fid,'\\cmidrule(lr){4-%d} \n ', nCols);
% fprintf(fid,' %s \\\\ \n', clmns);
% fprintf(fid,' \\cmidrule{1-%d}\n',nCols  );
% fprintf(fid,'\\endfirsthead\n');
% fprintf(fid,'\\multicolumn{%d}{l}\n',nCols);
% fprintf(fid,'{Continue from the previous page} \\\\ \n');
% fprintf(fid,'\\hline  & \\multicolumn{%d}{c}{\\textbf{%s}} \\\\ \n',nCols-1, mahakName);
% fprintf(fid,'\\cmidrule(lr){4-%d} \n',nCols);
% fprintf(fid,' %s \\\\ \n', clmns);
% fprintf(fid,' \\cmidrule{1-%d}\n',nCols);fprintf(fid,'\\endhead\n');
% fprintf(fid,'\\hline\n');
% for m=1:numel(methodsList)-2
%     fprintf(fid,'& ');
% end
% % fprintf(fid,'\\multicolumn{5}{r}{Continue on the next page...}\n');
% % fprintf(fid,'\\endfoot\n');
% fprintf(fid,'\\hhline{=');
% for m=methodsList+2
%     fprintf(fid,'=');
% end
% fprintf(fid,'}\n');
% % fprintf(fid,'\\endlastfoot\n');

for dsNo = 1:N
    curDS = dataSets{dsNo};
%     fprintf(fid,'\\multicolumn{%d}{l}{\\textbf{%s}}\\\\\\cmidrule{1-4}\n',nCols,curDS);
fprintf(fid,'\\addlinespace\n');
    fprintf(fid,'{\\textbf{%s}}  ',curDS);

    XData = 1:N;%{Results.fileName};
    for mm = 1:numel(mahaks)
        MeanData = [];
        mahak = mahaks{mm};
        mahakName = mahakNames{mm};
%         fprintf(fid,'\\multirow{%d}{*}{%s}',3,mahakName);
        fprintf(fid,'& {%s}',mahakName);
        
        for zooming =3:5%:4
            resultsFileName = sprintf('Results_%s_x%d_p3.mat',curDS,zooming);
            load(resultsFileName,'Results','methods','MSE','SSIM','FSIM','PSNR','TT','NIQE','CEIQ');
            data_curDS = eval(mahak);
            data = zeros(1,nMethods);
            data = mean(data_curDS(:,1:4));
            meanData = mean(data);
            minData = min(data(:)); maxData = max(data(:));
%             fprintf(fid,'\\multirow{%d}{*}{%s}',numel(mahaks),mahakName);
            if zooming >3, fprintf(fid,' & '); end
            fprintf(fid,' & %d ',zooming);
%             for xx=1:N
%                 fprintf(fid,'%s ',dataSets{xx});
                [~,sortedIdxInRow] = eval(['sort(data,''' mahakOptFuncSort{mm} ''')']);
                for m=methodsList
                    if m==sortedIdxInRow(1)
                        fprintf(fid,'& \\multicolumn{1}{>{\\cellcolor[gray]{.8}}c@{\\hspace{1mm}}}{$\\mathbf{%5.3f}$} ',data(m));
                    elseif m==sortedIdxInRow(2)
                        fprintf(fid,'& \\multicolumn{1}{>{\\cellcolor[gray]{.92}}c@{\\hspace{1mm}}}{${%5.3f}$} ',data(m));
                    else
                        fprintf(fid,' & %6.3f ',data(m));
                    end
                end
                fprintf(fid,'\\\\ \n');
                %         fprintf(fid,'\n');%MeanData(xx,m));
%             end
%             fprintf(fid,'\\hhline{=');
%             for m=methodsList
%                 fprintf(fid,'=');
%             end
%             fprintf(fid,'}\n');
        end
%         fprintf(fid,'\\addlinespace\n');
%         fprintf(fid,'\\hline\n');
    fprintf(fid,'\\cline{2-7}\n');
    end
    fprintf(fid,'\\cline{1-6}\n');
end
%         fprintf(fid,'Avg');
%         [~,sortedIdxInRow] = eval(['sort(meanData,''' mahakOptFuncSort{mm} ''')']);
%         for m=methodsList
%             if m==sortedIdxInRow(1)
%                 fprintf(fid,'& \\multicolumn{1}{>{\\cellcolor[gray]{.8}}c@{\\hspace{7mm}}}{$\\mathbf{%5.3f}$} ',meanData(m));
%             elseif m==sortedIdxInRow(2)
%                 fprintf(fid,'& \\multicolumn{1}{>{\\cellcolor[gray]{.92}}c@{\\hspace{7mm}}}{${%5.3f}$} ',meanData(m));
%             else
%                 fprintf(fid,'& $%5.3f$ ',meanData(m));
%             end
%         end
fprintf(fid,'\\\\ \n');

% fprintf(fid,'\\hline\n');
fprintf(fid,'\\end{tabular} \n');
fprintf(fid,'\\end{center}\n');
fprintf(fid,'\\vskip -0.25cm');
fprintf(fid,'\\end{table}\n');
fclose(fid);
