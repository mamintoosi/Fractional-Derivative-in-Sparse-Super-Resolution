# Fractional Derivative in Sparse Super Resolution
 
<br>
Here you can find MATLAB code for reproducing the results of the following paper:
"Fractional Derivative in Sparse Super Resolution"
<br>
In addition to MATLAB codes, a few Python script is also provided for creating tables of the paper.
<br><br>
<img src="images/FD-in-SR.jpg" />
<hr>

<b> Download Training and Test Images: </b> <br><br>
 The <b>Train</b> dataset is from the Yang's site: 
 <a href="http://www.ifp.illinois.edu/~jyang29/"> http://www.ifp.illinois.edu/~jyang29/ </a> which is provided here, if you download or clone this repository (in folder Data/Training).
 
 Test datasets in the paper are pupolar datasets in the field of Super-Resolution.
 The following datasets are used in the paper<br>
  <ul>
  <li>BSD100 </li>
  <li>MANGA109  </li>
  <li>Set5  </li>
  <li>Set14  </li>
  <li>URBAN100  </li>
</ul> 
which can be downloaded from <a href="https://cvnote.ddlee.cc/2019/09/22/image-super-resolution-datasets" > this site </a>. Note that the Ground truth images should be used as the input of the program. Producing low resolution images and then magnifiying will be done automatically by the program.
As an example dataset *Set5* is included in folder data/Test/Set5 of this repository.


<hr>

## The program

The core of the program is <a href="http://www.ifp.illinois.edu/~jyang29/"> Yang's </a> MATLAB code for his pioneering paper:<br>
J. Yang, J. Wright, T.S. Huang, and Y.Ma, "Image super-resolution via sparse
  representation", IEEE transactions on image processing, vol.19,
  no.11, pp.2861-2873, 2010

The main MATLAB file for running the program is: SparseSR_Zooming.m

SparseSR_Zooming.m is used for both Train and Test.
