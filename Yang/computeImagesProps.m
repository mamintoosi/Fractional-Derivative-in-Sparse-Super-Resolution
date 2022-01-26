function computeImagesProps
% M.Amintoosi

trProps = meanImagesWH('Data/training');
trProps.meanWH

masir = 'D:/Data/SR_testing_datasets/';
dataSets = {'BSDS100','Manga109','Set5','Set14','Urban100'}
N_dataSets = numel(dataSets);
for dsNo = 1:N_dataSets
    curDS = dataSets{dsNo};
    masirTestImages = sprintf('%s/%s/',masir,curDS);
    testProps(dsNo) = meanImagesWH(masirTestImages);
    s = sprintf('%s & %d & %d & %d \\\\',curDS,size(testProps(dsNo).Height,1),...
        testProps(dsNo).meanWH(1),testProps(dsNo).meanWH(2));
    disp(s)
end


function imProps = meanImagesWH(images_dir)
fpath = fullfile(images_dir, '*.png');  
img_dir = dir(fpath);

img_num = length(img_dir);

Height = zeros(img_num,1);
Width = zeros(1, img_num);

for num = 1:length(img_dir)
    imInfo = imfinfo(fullfile(images_dir, img_dir(num).name));
    Height(num) = imInfo.Height;
    Width(num) = imInfo.Width;    
end

imProps.Height = Height;
imProps.Width = Width;
imProps.meanWH = round([mean(Width), mean(Height)]);
