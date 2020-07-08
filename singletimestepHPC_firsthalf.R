require(spatialEco)
require(sp)
require(usedist)
require(rgeos)
require(raster)
require(spatstat)
require(igraph)
require(sf)
require(rgdal)
require(gdistance)
require(otuSummary)
require(gdata)
require(maptools)
require(tidyverse)
require(reshape2)
require(data.table)
#setwd("C:/Users/zjrobbin/Documents/GitHub/ConnectivityHPC/")
#getwd()
#Create master map of all habitat created by a conservation strategy
#args<-commandArgs(trailingOnly=TRUE)
#i=as.numeric(args[1])
eval(parse(text=paste(commandArgs(trailingOnly = TRUE), collapse=";")))

#Bring in ecoregion map to use for crs and extent template
Ecoregion <- raster("Inputs/Ecoregion100f.tif")

#Bring in landis standmap
Landis_standmap <- raster(paste("Inputs/Standmap100.tif",sep=""))

#Read in roads file
roads <- raster(paste("Inputs/roads.tif",sep=""))

XO<- list.files("Inputs",pattern = "^geo(.*)tif$")
ManyRunsStack<-raster::stack(paste0("Inputs/",XO))
SumStack<-sum(ManyRunsStack)

rm(ManyRunsStack)

#Create empty vectors for connectivity indices
nodes <- vector()
links <- vector()
avgnode <- vector()
totnode <- vector()
avgLCP <- vector()
avgENN <- vector()
density <- vector()
transitivity <- vector()

#Time steps
TimestepList <- as.character(seq(from=0, to=80, by=10))

#Connectivity analysis
 


Longleaf<-"PinuPalu"
Loblolly<-"PinuTaed"
Pine<- c("PinuEchi","PinuTaed","PinuVirg")
Hardwood<-c("QuerAlba","AcerRubr","LiriTuli","LiquStyr","OxydArbo","CornFlor")

Year0<-list.files("Inputs",pattern=(".img$"))

Longleaf_Stack<-raster(paste0("Inputs/",Year0[Year0 %in% paste0("bio-", Longleaf,"-",i,".img")]))
Loblolly_Stack<-raster(paste0("Inputs/",Year0[Year0 %in% paste0("bio-", Loblolly,"-",i,".img")]))
Pine_Stack<-raster::stack(paste0("Inputs/",Year0[Year0 %in% paste0("bio-", Pine,"-",i,".img")]))
Hardwood_Stack<-raster::stack(paste0("Inputs/",Year0[Year0 %in% paste0("bio-", Hardwood,"-",i,".img")]))
Total<-raster(paste0("Inputs/",Year0[Year0 %in% paste0("bio-TotalBiomass-", i, ".img")]))


###Reclassification of biomass into community types

###Rule 1 
Longleaf_Stack[Longleaf_Stack> 0.25*(Total),]<-1
Longleaf_Stack[!Longleaf_Stack==1]<-999
### Rule 2
Loblolly_Stack[Loblolly_Stack> 0.9*(Total),]<-2
Loblolly_Stack[!Loblolly_Stack==2]<-999
### Rule 3
Pine_Stack[Pine_Stack> 0.65*(Total),]<-3
Pine_Stack[!Pine_Stack==3]<-999
### Rule 4
Hardwood_Stack[Hardwood_Stack>0.5*(Total),]<-4
Hardwood_Stack[!Hardwood_Stack==4]<-999
### Rule 5
Total[Total >0,]<-5

bigstack<-stack(Longleaf_Stack, Loblolly_Stack, Pine_Stack, Hardwood_Stack, Total)
test_stack<-min(bigstack)
crs(test_stack) <- "+proj=utm +zone=17 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
extent(test_stack)<-raster::extent(Ecoregion)

median0 <- raster(paste0('Inputs/',Year0[Year0 %in% paste0("AGE-MED-",i,".img")]))
crs(median0) <- "+proj=utm +zone=17 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
extent(median0)<-raster::extent(Ecoregion)

#use to incorporate land use change
#LU0 <- raster(paste("C:/Users/tgmozele/Desktop/LCP sensitivity test/geo2noLUC/land-use-", i, ".tif",sep=""))

#use to not incorporate land use change, but establish BAU land use types
LU0 <- raster("Inputs/NLCD100.tif")

#Create a raster that will become resistance raster
test_raster <- test_stack

#Assign projection and reformat to ecoregion extent for the resistance raster
crs(test_raster) <- "+proj=utm +zone=17 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
extent(test_raster)<-raster::extent(Ecoregion)

#Assign values to resistance raster
#longleaf community comp
test_raster[test_stack == 1 & median0 %in% c(0:1),] <- (1/100)
test_raster[test_stack == 1 & median0 %in% c(2:5),] <- (1/95)
test_raster[test_stack == 1 & median0 %in% c(6:7),] <- (1/85)
test_raster[test_stack == 1 & median0 %in% c(8:9),] <- (1/50)
test_raster[test_stack == 1 & median0 %in% c(10:20),] <- (1/10)
test_raster[test_stack == 1 & median0 %in% c(21:34),] <- (1/5)
test_raster[test_stack == 1 & median0 >= 35,] <- 1
#test_raster[test_stack == 3 & median0 %in% c(0:5),] <- (1/95)
#test_raster[test_stack == 3 & median0 %in% c(6:10),] <- (1/80)
#test_raster[test_stack == 3 & median0 %in% c(11:20),] <- (1/25)
#test_raster[test_stack == 3 & median0 %in% c(21:34),] <- (1/5)
#test_raster[test_stack == 3 & median0 >= 35,] <- 1

#pine plantation community type (was pine mix)
test_raster[test_stack == 2 & median0 %in% c(0:5),] <- (1/100)
test_raster[test_stack == 2 & median0 %in% c(6:10),] <- (1/90)
test_raster[test_stack == 2 & median0 %in% c(11:20),] <- (1/80)
test_raster[test_stack == 2 & median0 %in% c(21:30),] <- (1/70)
test_raster[test_stack == 2 & median0 >= 31,] <- (1/60)

#pine mix community type (was lob_)
test_raster[test_stack == 3 & median0 %in% c(0:5),] <- (1/95)
test_raster[test_stack == 3 & median0 %in% c(6:10),] <- (1/80)
test_raster[test_stack == 3 & median0 %in% c(11:20),] <- (1/40)
test_raster[test_stack == 3 & median0 %in% c(21:34),] <- (1/30)
test_raster[test_stack == 3 & median0 >= 35,] <- (1/20)
#test_raster[test_stack == 3 & median0 %in% c(0:5),] <- (1/95)
#test_raster[test_stack == 3 & median0 %in% c(6:10),] <- (1/80)
#test_raster[test_stack == 3 & median0 %in% c(11:20),] <- (1/25)
#test_raster[test_stack == 3 & median0 %in% c(21:34),] <- (1/5)
#test_raster[test_stack == 3 & median0 >= 35,] <- 1

#hardwood community type (was mix)
test_raster[test_stack == 4 & median0 %in% c(0:10),] <- (1/100)
test_raster[test_stack == 4 & median0 %in% c(11:20),] <- (1/95)
test_raster[test_stack == 4 & median0 %in% c(21:30),] <- (1/90)
test_raster[test_stack == 4 & median0 >= 31,] <- (1/85)

#mixed forest community type (was hardwood)
test_raster[test_stack == 5 & median0 %in% c(0:10),] <- (1/100)
test_raster[test_stack == 5 & median0 %in% c(11:20),] <- (1/95)
test_raster[test_stack == 5 & median0 %in% c(21:30),] <- (1/90)
test_raster[test_stack == 5 & median0 >= 31,] <- (1/80)
#test_raster[test_stack == 5 & median0 %in% c(0:10),] <- (1/100)
#test_raster[test_stack == 5 & median0 %in% c(11:20),] <- (1/85)
#test_raster[test_stack == 5 & median0 %in% c(21:30),] <- (1/70)
#test_raster[test_stack == 5 & median0 >= 31,] <- (1/60)

test_raster2 <- test_raster

test_raster2[test_raster ==0] <- NA

#land use types
test_raster2[LU0 == 82] <- (1/90) #cropland
test_raster2[LU0 == 81] <- (1/90) #hay/pasture
test_raster2[LU0 == 11] <- (1/100) #water
test_raster2[LU0 == 24] <- (1/100) #developed, high intensity
test_raster2[LU0 == 23] <- (1/95) #developed, med intensity
test_raster2[LU0 == 22] <- (1/85) #developed, low intensity
test_raster2[LU0 == 31] <- (1/90) #barren land
#test_raster2[LU0 == 6] <- (1/100) #mining

test_raster2[test_raster2 ==0] <- (1/90)

#roads
test_raster2[roads %in% c(1:2)] <- (1/100)
test_raster2[roads %in% c(3:4)] <- (1/95)
test_raster2[roads %in% c(5:89)] <- (1/90)

test_raster3 <- test_raster2
test_raster3[test_raster3 >0.1] <- 1
test_raster3[test_raster3 < 1] <- 0
habitat_raster <- overlay(test_raster3, SumStack, fun=function(x,y){(x*y)} )

#Cluster habitat cells into habitat nodes using quintiles of occurrence

LikelyHabitat8<-habitat_raster
LikelyHabitat8[LikelyHabitat8%in%c(0:36),]<-NA
pol8 <- rasterToPolygons(LikelyHabitat8)
proj4string(pol8) = "+proj=utm +zone=17 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
pol8$ID<-seq(1,length(pol8[1]))
polbuf <- gBuffer(pol8, byid=TRUE, id=pol8$ID, width=1.0, quadsegs=5, capStyle="ROUND",
                  joinStyle="ROUND", mitreLimit=1.0)
polbufdis <- gUnaryUnion(polbuf, id = NULL, checkValidity=NULL)
a<-raster::disaggregate(polbufdis)

LikelyHabitat5<-habitat_raster
LikelyHabitat5[LikelyHabitat5%in%c(0:27,37:45),]<-NA
pol5 <- rasterToPolygons(LikelyHabitat5)
proj4string(pol5) = "+proj=utm +zone=17 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
pol5$ID<-seq(1,length(pol5[1]))
polbuf <- gBuffer(pol5, byid=TRUE, id=pol5$ID, width=1.0, quadsegs=5, capStyle="ROUND",
                  joinStyle="ROUND", mitreLimit=1.0)
polbufdis <- gUnaryUnion(polbuf, id = NULL, checkValidity=NULL)
b<-raster::disaggregate(polbufdis)

LikelyHabitat3<-habitat_raster
LikelyHabitat3[LikelyHabitat3%in%c(0:18,28:45),]<-NA
pol3 <- rasterToPolygons(LikelyHabitat3)
proj4string(pol3) = "+proj=utm +zone=17 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
pol3$ID<-seq(1,length(pol3[1]))
polbuf <- gBuffer(pol3, byid=TRUE, id=pol3$ID, width=1.0, quadsegs=5, capStyle="ROUND",
                  joinStyle="ROUND", mitreLimit=1.0)
polbufdis <- gUnaryUnion(polbuf, id = NULL, checkValidity=NULL)
c<-raster::disaggregate(polbufdis)

LikelyHabitat1<-habitat_raster
LikelyHabitat1[LikelyHabitat1%in%c(0:9,19:45),]<-NA
pol1 <- rasterToPolygons(LikelyHabitat1)
proj4string(pol1) = "+proj=utm +zone=17 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
pol1$ID<-seq(1,length(pol1[1]))
polbuf <- gBuffer(pol1, byid=TRUE, id=pol1$ID, width=1.0, quadsegs=5, capStyle="ROUND",
                  joinStyle="ROUND", mitreLimit=1.0)
polbufdis <- gUnaryUnion(polbuf, id = NULL, checkValidity=NULL)
d<-raster::disaggregate(polbufdis)

LikelyHabitat<-habitat_raster
LikelyHabitat[LikelyHabitat%in%c(0,10:45),]<-NA
pol <- rasterToPolygons(LikelyHabitat)
proj4string(pol) = "+proj=utm +zone=17 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
pol$ID<-seq(1,length(pol[1]))
polbuf <- gBuffer(pol, byid=TRUE, id=pol$ID, width=1.0, quadsegs=5, capStyle="ROUND",
                  joinStyle="ROUND", mitreLimit=1.0)
polbufdis <- gUnaryUnion(polbuf, id = NULL, checkValidity=NULL)
e<-raster::disaggregate(polbufdis)

#Bring quintile-based habitat nodes together into one SpatialPolygonsDataFrame, find area of nodes, and assign numbers
polys <- bind(a,b,c,d,e)
data<-data.frame(ID=seq(1,length(polys)))
pol1_dis<-SpatialPolygonsDataFrame(polys,data)
pol1_dis$area_ha <- raster::area(pol1_dis)/10000

pol1_dis$num1 <- seq(from = 1, to= length(pol1_dis), by=1)
pol1_dis$num2 <- seq(from = 1, to= length(pol1_dis), by=1)

#Assign weight to habitat by type and area to be used in Conefor
pol1_dis$weight <- NA
pol1_dis$weight <- log(pol1_dis$area_ha)

#Restrict habitat patches to those 2 hectares and larger, reassign ID's
pol1_dis <- pol1_dis[pol1_dis$area_ha >= 2,]
pol1_dis$ID<-seq(from = 1, to= length(pol1_dis), by=1)

#Make habitat nodes file to be used for Conefor
maketext <- cbind(pol1_dis$ID, pol1_dis$weight)
write.table(maketext, file=paste0("Outputs/nodes_TMgeos1_Thisoneisdiffernt78",i,".txt"), sep = "\t", row.names = FALSE, col.names = FALSE)
