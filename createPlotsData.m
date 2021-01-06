function createPlotsData(curDS,masirArticle,gam)
% M.Amintoosi, HSU 2016- FUM 2019
% Creating TikZ Plots in LaTeX

if nargin<3
    gam = 1;
end
masirOutput = [masirArticle 'output/'];
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
nMethods = length(methods);

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
    %     MeanData = [MeanData; meanData];
    minData = min(data(:)); maxData = max(data(:));
    yTool = maxData-minData;
    yMin = minData - .1*yTool;
    yMax = maxData + .1*yTool;
    ycm = 3/yTool;
    xcm = 16/N;
    
    %         plotDataFileName =  sprintf('doc%s/%s_plots/plotData_%s_%s.txt',dbName,dbName,mahaks{mm},methods{m});
    plotDataFileName =  sprintf('%s/plotsData_%s.txt',outputDir,mahaks{mm});
    fid = fopen(plotDataFileName,'wt');
    fprintf(fid,'imNo');
    for m=methodsList
        fprintf(fid,' %5s ',methods{m});
    end
    fprintf(fid,'\n');
    for xx=1:N
        fprintf(fid,'%4d ',XData(xx));
        for m=methodsList
            fprintf(fid,'%6.3f ',data(xx,m));
        end
        fprintf(fid,'\n');%MeanData(xx,m));
    end
    fclose(fid);
    
    
    %     tikzpicFileName =  sprintf('doc%s/%s_plots/tikzpicDataMean_%s.txt',dbName,dbName,mahaks{mm});
    tikzpicFileName =  sprintf('%s/tikzpicDataMean_%s.txt',outputDir,mahaks{mm});
    [pathstr,fileName,ext] = fileparts(tikzpicFileName);
    fprintf('\\input{%s%s}\n',fileName,ext)
    
    fidTikzpic = fopen(tikzpicFileName,'wt');
%     fprintf(fidTikzpic,'\n');
    [pathstr,fileName,ext] = fileparts(plotDataFileName);

    fprintf(fidTikzpic,'\\pgfplotstableread{%s%s}{\\table}\n',fileName,ext);
    fprintf(fidTikzpic,'\\begin{tikzpicture}[scale=.8]\n');
    fprintf(fidTikzpic,'\\pgfplotsset{every axis legend/.append style={at={(0.5,1.03)},anchor=south}}\n');
    fprintf(fidTikzpic,'\\begin{axis}[cycle list name=mylist,legend columns=2, \n');% semilogyaxis for TT
    fprintf(fidTikzpic,'xlabel = Image No., ylabel=%s ,y=%6.4f cm,x=%6.4f cm,\n',mahakNames{mm},ycm,xcm);
    fprintf(fidTikzpic,' xmin=0, xmax=%d, ymin=%4.2f, ymax=%4.2f]\n',...
        N+1, yMin,yMax);
    for m=methodsList
        fprintf(fidTikzpic,'\\addplot+[smooth] table[x=imNo,y=%s] from \\table;\n',methods{m});
    end
    fprintf(fidTikzpic,'\\legend{\n');
    [~,sortedIdxInRow] = eval(['sort(meanData,''' mahakOptFuncSort{mm} ''')']);
    for m=methodsList
        %         for m=methodsList
        if m==sortedIdxInRow(1)
            fprintf(fidTikzpic,'\\textbf{%s (Avg=%6.3f)}, ',methods{m},meanData(m));
        else
            fprintf(fidTikzpic,'%s (Avg=%6.3f), ',methods{m},meanData(m));
        end
        %         end
    end
    fprintf(fidTikzpic,'}\n');
    fprintf(fidTikzpic,'\\end{axis}\n');
    fprintf(fidTikzpic,'\\draw (-.5,4) node[above] {(%s)};\n',char(96+mm));
    fprintf(fidTikzpic,'\\end{tikzpicture}\n');
    fclose(fidTikzpic);       
end

curDir = pwd;
cd(outputDir);
cmd = sprintf('pdflatex Plots_and_Tables.tex');
system(cmd)
cmd = sprintf('pdfcrop Plots_and_Tables.pdf %s/%s_plots.pdf',masirArticle,curDS);
system(cmd)
cd(curDir);

