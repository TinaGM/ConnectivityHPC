#install rgdal
module load R/gcc_4.8.5_R-3.5.1 
setenv LD_LIBRARY_PATH /usr/local/apps/gdal/gcc483-2.1.1/lib:$LD_LIBRARY_PATH 
setenv PATH /usr/local/apps/gdal/gcc483-2.1.1/bin:$PATH 
setenv LD_LIBRARY_PATH /usr/local/apps/proj/gcc483-4.9.3/lib:$LD_LIBRARY_PATH 
setenv LD_LIBRARY_PATH /usr/local/apps/geos/gcc483-3.4/lib:$LD_LIBRARY_PATH
setenv PATH /usr/local/apps/geos/gcc483-3.4/bin:$PATH
setenv LD_LIBRARY_PATH /usr/local/apps/geos/gcc483-3.4/lib:$LD_LIBRARY_PATH
setenv PATH /usr/local/apps/geos/gcc483-3.4/bin:$PATH
R
install.packages("rgeos",repos="http://cran.us.r-project.org")
install.packages("rgdal", repos='http://cran.us.r-project.org',configure.args = c("--with-proj-include=/usr/local/apps/proj/gcc483-4.9.3/include","--with-proj-lib=/usr/local/apps/proj/gcc483-4.9.3/lib" )) 
install.packages("rgeos",repos="http://cran.us.r-project.org")
install.packages("sp",repos="http://cran.us.r-project.org")
install.packages("usedist",repos="http://cran.us.r-project.org")
install.packages("raster",repos="http://cran.us.r-project.org")
install.packages("spatstat",repos="http://cran.us.r-project.org")
install.packages("igraph",repos="http://cran.us.r-project.org")
install.packages("sf",repos="http://cran.us.r-project.org")
install.packages("rgdal",repos="http://cran.us.r-project.org")
install.packages("gdistance",repos="http://cran.us.r-project.org")
install.packages("otuSummary",repos="http://cran.us.r-project.org")
install.packages("gdata",repos="http://cran.us.r-project.org")
install.packages("maptools",repos="http://cran.us.r-project.org")
install.packages("tidyverse",repos="http://cran.us.r-project.org")
install.packages("reshape2",repos="http://cran.us.r-project.org")
install.packages("data.table",repos="http://cran.us.r-project.org")
