Fractional Derivative in Sparse Super Resolution
==========
 [![repo size](https://img.shields.io/github/repo-size/mamintoosi/Fractional-Derivative-in-Sparse-Super-Resolution.svg)](https://github.com/mamintoosi/Fractional-Derivative-in-Sparse-Super-Resolution/archive/master.zip)
 [![GitHub forks](https://img.shields.io/github/forks/mamintoosi/Fractional-Derivative-in-Sparse-Super-Resolution)](https://github.com/mamintoosi/Fractional-Derivative-in-Sparse-Super-Resolution/network)
[![GitHub issues](https://img.shields.io/github/issues/mamintoosi/Fractional-Derivative-in-Sparse-Super-Resolution)](https://github.com/mamintoosi/Fractional-Derivative-in-Sparse-Super-Resolution/issues)
[![GitHub license](https://img.shields.io/github/license/mamintoosi/Fractional-Derivative-in-Sparse-Super-Resolution)](https://github.com/mamintoosi/Fractional-Derivative-in-Sparse-Super-Resolution/blob/main/LICENSE)
[PDF](https://www.dropbox.com/s/fhs8nd0zedszz4r/1401-Fractional%20derivative%20approach%20to%20sparse%20super-resolution.pdf?dl=1)

 
<br>
Here you can find MATLAB code for reproducing the results of the following paper:
"Fractional Derivative in Sparse Super Resolution"
<br>
In addition to MATLAB codes, a Python script is also provided for creating tables of the paper.
<br><br>
<img src="images/FD-in-SR.jpg" />
<hr>

## Dataset 

<b> Download Training and Test Images: </b> <br><br>
 The <b>Train</b> dataset is from the Yang's site: 
 <a href="http://www.ifp.illinois.edu/~jyang29/"> http://www.ifp.illinois.edu/~jyang29/ </a> which is provided here, if you download or clone this repository (in folder Data/Training).
 
 Test datasets in the paper are pupolar datasets in the field of Super-Resolution.
 The following datasets are used in the paper:<br>
  <ul>
  <li>BSD100 </li>
  <li>MANGA109  </li>
  <li>Set5  </li>
  <li>Set14  </li>
  <li>URBAN100  </li>
</ul> 
which can be downloaded from <a href="https://cvnote.ddlee.cc/2019/09/22/image-super-resolution-datasets" > this site </a>. Note that the Ground truth images should be used as the input of the program. Producing low resolution images and then magnifying will be done automatically by the program.
Two datasets *Set5* and *Set14* are included in folder *data/Test* of this repository.

<hr>

Here adding Fractional Derivative for enhancement of two following SR methods is investigated:

```
@article{yang2010,
  title={Image super-resolution via sparse representation},
  author={Yang, Jianchao and Wright, John and Huang, Thomas S and Ma, Yi},
  journal={IEEE transactions on image processing},
  volume={19},
  number={11},
  pages={2861--2873},
  year={2010},
  publisher={IEEE}
}
```


```
@article{kim2017single,
  title={Single Image Super-Interpolation using Adjusted Self-Exemplars},
  author={Kim, Hyun-Ho and Choi, Jae-Seok and Kim, Munchurl},
  journal={Electronic Imaging},
  volume={2017},
  number={17},
  pages={81--86},
  year={2017},
  publisher={Society for Imaging Science and Technology}
}
```


## The program
For each of the above papers, the original code provided by their authors are used here, and modified for adding fractional derivative.

In each of two folders *Yang* and *Kim*, you can find the modified version of the original papers. In each folder *main.m* is the main MATLAB file, that should be run for reproducing the results of the paper.


# The programs
## Yang Folder
The core of the program is <a href="http://www.ifp.illinois.edu/~jyang29/"> Yang's </a> MATLAB code for his pioneering paper.

The main MATLAB file for running the program is: *main.m*

*main.m* is used for both Train and Test.

### Test

The simple approach is using the pre-trained dictionaries, which are in folder *Data/Dictionary*. Training the dictionary is a time-consuming task, hence we provided our trained dictionaries over various parameters, mentioned in the paper. BTW every one could be use *SparseSR_Zooming.m* and the Training images for creating his dictionary with his desired parameter settings, or arbitrary training images.

All of the test images are about 300 MB, but you can test only one dataset, by editing the following line in *main.m*:<br>
*dataSets = {'BSDS100','Manga109','Set5','Set14','Urban100'}*
<br>
After setting the paths and parameters, you can run the program. 

Optionally you can un-comment *createLatexImageTables*, *createPlotsData* and *createTableData* for producing some tables demonstrated in the paper.<br>
Also *createSummaryTableDataSets.m* and *createSummaryTableDataSets_zooming.m* can be used for some other results, but these files are need some manual setting for reading the produced results.

### Training

For training the program using arbitrary images, after setting the related Paths, you should set *skip_smp_training* and *skip_dictionary_training* to false. The default values of these variables are true,  which is used for testing the program with pre-trained dictionaries.
When *skip_smp_training=false*, andom 50000 small patches from train images are selected and corresponding low and high-resolutions of the patches saved in *Xh, Xl*. After that, if *skip_dictionary_training=false*, these variables will be used to *coupled_dic_train()* for creating the appropriate dictionary. 
<br>
The resulting dictionary will be saved as *Data/Dictionary/Dictionary.mat*. 
Some previous trained dictionaries were renamed manually for testing purposes.

#### Image Tables

The aforementioned MATLAB files produce LaTeX tables and recinstructed images of various methods. But for producing images such as Figure 7 in the paper (the top Zebra image), in which a portion of the images is enlarged, a python script is prepared: *makeImagetable.ipynb*. This jupyter notebook can be run after running the MATLAB codes on test images.

# Caution

Running the program with default parameters and for three zooming factors 3,4,5 and on all of the datasets, will produce huge number if images, which require about <b>3 Giga byte</b> of storage space. 
Each zooming factor requires about 800 MB of storage space.

## Kim Folder
Here *main.m* is the main MATLAB script and *createSummaryTableDataSets.m* is for producing LaTeX tables.
