function createTableData(curDS,masirOutput,gam)
% M.Amintoosi, HSU 2016- FUM 2019
% Creating Tables in LaTeX

if nargin<3
    gam = 1;
end
outputDir = sprintf('%s/%s',masirOutput,curDS);
resultsFileName = sprintf('Results_%s.mat',curDS);
load(resultsFileName,'Results','methods','MSE','SSIM','FSIM','PSNR','TT');

mahaks = {'MSE','PSNR','SSIM','FSIM','TT'};
mahakNames = {'MSE','PSNR','SSIM','FSIM','RunTime'};
mahakOptFunc = {'min','max','max','max','min'};
mahakNonOptFunc = {'max','min','min','min','max'};
mahakOptFuncSort = {'ascend','descend','descend','descend','ascend'};

N = numel(Results);

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
    data = eval(mahak);
%     data(:,end) =[]; % Discarding 1.2
    meanData = mean(data);
    %     optData = eval([mahakOptFunc{mm} '(meanData)']);
    
    %     MeanData = [MeanData; meanData];
    minData = min(data(:)); maxData = max(data(:));
    
    clmns = sprintf('Im No. & File Name ');
    for m=methodsList
        clmns = [clmns sprintf(' & %5s ',methods{m})];
    end
    nCols = numel(methodsList)+2; % 1->2 Adding image file name
    
    %         plotDataFileName =  sprintf('doc%s/%s_plots/plotData_%s_%s.txt',curDS,curDS,mahaks{mm},methods{m});
    tableDataFileName =  sprintf('%s/Tbl_%s.txt',outputDir,mahaks{mm});
    [pathstr,fileName,ext] = fileparts(tableDataFileName);
    fprintf('\\input{%s%s}\n',fileName,ext)
    
    fid = fopen(tableDataFileName,'wt');
    %     fprintf(fid,'\\begin{table}\n');
    fprintf(fid,'\\begin{center}\n');
    fprintf(fid,'\\begin{longtable}{c@{\\hspace{3mm}}c@{\\hspace{3mm}}');
    for m=methodsList
        fprintf(fid,'c@{\\hspace{3mm}}');
    end
    fprintf(fid,'}\n');
    fprintf(fid,'\\caption{Results of \\textbf{%s} on \\textit{%s} (magnification factor=3).}\n',mahakName,curDS);
    fprintf(fid,'\\label{tab:%s:%s}\\\\\n',curDS,mahakName);
    fprintf(fid,'\\hline\n');
    
    fprintf(fid,' & \\multicolumn{%d}{c}{\\textbf{%s}} \\\\',nCols-2,mahakName);
    fprintf(fid,'\\cmidrule(lr){3-%d} \n ', nCols);
    fprintf(fid,' %s \\\\ \n', clmns);
    fprintf(fid,' \\cmidrule{1-%d}\n',nCols  );
    fprintf(fid,'\\endfirsthead\n');
    fprintf(fid,'\\multicolumn{%d}{l}\n',nCols);
    fprintf(fid,'{Continue from the previous page (Dataset:%s)} \\\\ \n',curDS);
    fprintf(fid,'\\hline  & \\multicolumn{%d}{c}{\\textbf{%s}} \\\\ \n',nCols-1, mahakName);
    fprintf(fid,'\\cmidrule(lr){3-%d} \n',nCols);
    fprintf(fid,' %s \\\\ \n', clmns);
    fprintf(fid,' \\cmidrule{1-%d}\n',nCols);fprintf(fid,'\\endhead\n');
    fprintf(fid,'\\hline\n');
    for m=1:numel(methodsList)-4
        fprintf(fid,'& ');
    end
    fprintf(fid,'\\multicolumn{5}{r}{Continue on the next page...}\n');
    fprintf(fid,'\\endfoot\n');
    fprintf(fid,'\\hhline{==');
    for m=methodsList
        fprintf(fid,'=');
    end
    fprintf(fid,'}\n');
    fprintf(fid,'\\endlastfoot\n');
    %     fprintf(fid,'\n');
    %     [~,bestIdxInRow] = eval([mahakOptFunc{mm} '(data'')']);
    %     for xx=1:N
    %         fprintf(fid,'%4d ',XData(xx));
    %         for m=methodsList
    %             if m==bestIdxInRow(xx)
    %                 fprintf(fid,'& \\multicolumn{1}{>{\\cellcolor[gray]{.95}}c|}{$\\mathbf{%5.3f}$} ',data(xx,m));
    %             else
    %                 fprintf(fid,' & %6.3f ',data(xx,m));
    %             end
    %         end
    %         fprintf(fid,'\\\\ \n');
    %         %         fprintf(fid,'\n');%MeanData(xx,m));
    %     end
    
    for xx=1:N
        fname = strrep(Results(xx).fileName,'_','\_');
        fprintf(fid,'%4d & {\\footnotesize %s}',XData(xx),fname);
        [~,sortedIdxInRow] = eval(['sort(data(xx,:),''' mahakOptFuncSort{mm} ''')']);
        for m=methodsList
            if m==sortedIdxInRow(1)
                fprintf(fid,'& \\multicolumn{1}{>{\\cellcolor[gray]{.8}}c@{\\hspace{3mm}}}{$\\mathbf{%5.3f}$} ',data(xx,m));
            elseif m==sortedIdxInRow(2)
                fprintf(fid,'& \\multicolumn{1}{>{\\cellcolor[gray]{.92}}c@{\\hspace{3mm}}}{${%5.3f}$} ',data(xx,m));
            else
                fprintf(fid,' & %6.3f ',data(xx,m));
            end
        end
        fprintf(fid,'\\\\ \n');
        %         fprintf(fid,'\n');%MeanData(xx,m));
    end
    
    fprintf(fid,'\\hhline{==');
    for m=methodsList
        fprintf(fid,'=');
    end
    fprintf(fid,'}\n');
    fprintf(fid,'& Avg');
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