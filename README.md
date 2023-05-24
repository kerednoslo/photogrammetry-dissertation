# stereo-photogrammetry
Collection of matlab scripts to process stereo images and create height fields. The scripts here rely on opencv 2.4 and the mex bridge to that library in the mexopencv project

#USAGE
Run the driver script dereks_stereoPhoto_wrapper_gitlab.m. Point the baseDir variable to the directory containing the images and calibration information. FOllow the naming structure. The intermediate products of rectified images and disparity map are also saved in their respective folders. The power spectrum in 2D and 1D radial averages are computed, plotted, and saved as data and as images.

#Build
Instructions to build opencv and mexopenv.

Install conda and create an environment called opencv, using python2.7 and install numpy. This is not required for the stereo photogrammetry, but helps keep things clean ifyou have a system python like macos does.

	$ conda create -n opencv python=2.7
	$ conda activate opencv
	$ conda install numpy

First clone opencv and checkout branch 2.4

	$ git clone https://github.com/opencv/opencv.git
	$ git checkout 2.4
	$ cd opencv
	
Now make a build directory and run cmake. You'll need to have cmake, make, pkgconfig and a C++ compiler available. Replace '~/bin/opencv/' with somewhere in your home directory to install opencv.
	
	$ mkdir build
	$ cd build
	$ cmake -DCMAKE_INSTALL_PREFIX=~/bin/opencv/  ../
	$ make install
	
If you are on macos, you'll need to make sure you aren't building for the wrong kernel target
	
	$ cmake -DCMAKE_INSTALL_PREFIX=~/bin/opencv/ -DCMAKE_OSX_DEPLOYMENT_TARGET=10.15 ../
	$ make install
	
You are now done building opencv. Now on to mexopencv. Clone the mexopencv library and checkout branch v2.4

	$ git clone https://github.com/kyamagu/mexopencv.git
	$ cd mexopencv
	
To build, you will need to know the directory of your matlab installation, as well as tell pkgconfig where the files are. If you are using windows, you can do this all within matlab, and should follow the directions on the github repo for mexopencv. If you're on macos or linux, then proceed

	$ export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:~/bin/opencv/lib/pkgconfig
	$ make MATLABDIR=/Applications/MATLAB_R2022b.app/
	
Now you are finished with mexopencv. To use the scripts. you will have to tell matlab where everything is.

	$  DYLD_LIBRARY_PATH=/Users/derekolsonnn/bin/opencv/lib/ ./matlab
	
from within matlab, add the mexopencv path to matlab, and this repository, and run the script
	

	