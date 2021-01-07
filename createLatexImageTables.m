function createLatexImageTables(resultsFileName,curDS,masirArticle,nRows)
% M.Amintoosi, HSU 2019
% Creating image tables in LaTeX
if nargin<3
    nRows = 10;
end

masirOutput = [masirArticle 'output/'];
outputDir = sprintf('%s/%s',masirOutput,curDS);
%resultsFileName = sprintf('Results_%s.mat',curDS);
load(resultsFileName,'Results','methods');

% Results(3) = [];
N = numel(Results);
if nRows>N
    nRows = N;
end
imList = floor(linspace(1,N,nRows));

nMethods = numel(methods);
coefImW = 1/(nMethods+3);
% options.step = 1;
% tablePostfix = '';
tableFileName =  sprintf('%s/imgTable.tex',outputDir);%,tablePostfix);
% tableFileName =  sprintf('doc500px/imgTable_%s.tex',tablePostfix);
fid = fopen(tableFileName,'wt');
%fprintf(fid,'\\begin{table*}\n');
%fprintf(fid,'\\centering\n');
fprintf(fid,'\\begin{tabular}{|c|c|');
for m=1:nMethods
    fprintf(fid,'c|');
end
fprintf(fid,'}\n');
%fprintf(fid,'\\caption{%s}\n',tablePostfix); %sideway
fprintf(fid,'\\hline\n');
% \hhline{|=====|}
fprintf(fid,' Im No. & HR ');
for m=1:nMethods
    fprintf(fid,'& %s ',methods{m});
end
fprintf(fid,'\\\\ \n');
fprintf(fid,'\\hhline{|==');
for m=1:nMethods
    fprintf(fid,'=');
end
fprintf(fid,'|}\n');
for ii=imList %1:gam:numel(Results)% 
%     masir = sprintf('output/%s/%s',curDS, Results(ii).fileName);
    masir = sprintf('%s', Results(ii).fileName);
    hImFileName = sprintf('%s/high.jpg',masir);
    fprintf(fid,'%d ',ii);
    fprintf(fid,'& \\includegraphics[width=%4.2f\\textwidth]{%s} ',coefImW,hImFileName);
    for m=1:nMethods
        [pathstr,fileName,ext] = fileparts(Results(ii).method(m).outputFileName);
        imFileName = sprintf('%s/%s%s',masir,fileName,ext);
        fprintf(fid,'& \\includegraphics[width=%4.2f\\textwidth]{%s} ',coefImW,imFileName);
    end
    fprintf(fid,'\\\\ \n');
end
fprintf(fid,'\n\\hline\n');
fprintf(fid,'\\end{tabular} \n');
%fprintf(fid,'\\caption{%s}\n\\end{table*}\n',tablePostfix); %sideway
fclose(fid);

[pathstr,fileName,ext] = fileparts(tableFileName);
fprintf('\\input{%s%s}\n',fileName,ext)
%%
curDir = pwd;
cd(outputDir);
cmd = sprintf('xelatex images.tex');
system(cmd)
cmd = sprintf('pdfcrop images.pdf %s/%s_images.pdf',masirArticle,curDS);
system(cmd)
cd(curDir);

