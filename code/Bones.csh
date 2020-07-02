#install rgdal
module load R/gcc_4.8.5_R-3.5.1 
setenv LD_LIBRARY_PATH /usr/local/apps/gdal/gcc483-2.1.1/lib:$LD_LIBRARY_PATH 
setenv PATH /usr/local/apps/gdal/gcc483-2.1.1/bin:$PATH 
setenv LD_LIBRARY_PATH /usr/local/apps/proj/gcc483-4.9.3/lib:$LD_LIBRARY_PATH 
setenv LD_LIBRARY_PATH /usr/local/apps/geos/gcc483-3.4/lib:$LD_LIBRARY_PATH
setenv PATH /usr/local/apps/geos/gcc483-3.4/bin:$PATH
setenv LD_LIBRARY_PATH /usr/local/apps/geos/gcc483-3.4/lib:$LD_LIBRARY_PATH
setenv PATH /usr/local/apps/geos/gcc483-3.4/bin:$PATH
R CMD BATCH ZR_Packages.R
#!/bin/tcsh
#BSUB -n 4
#BSUB -W 600
#BSUB -R span[hosts=1] 
#BSUB -R "rusage[mem=16000]"
#BSUB -x 
#BSUB -J mycode
#BSUB -o output_file.%J
#BSUB -J program_T=200K 
