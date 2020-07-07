##you will need all of these packages installed susan
# install.packages('sf')
# install.packages('sp')
# install.packages('stringr')
# install.packages('janitor')
# install.packages('mapview')
# install.packages('rgdal')
# install.packages('parzer')


##mapview tutorial https://r-spatial.github.io/mapview/index.html

###load packages

library(sf)
library(sp)
library(stringr)
library(parzer)
library(janitor)
library(mapview)
library(rgdal)
library(raster)

#read file from local source

fname <- "/Users/BJB/Dropbox/ODD_GPSwork/susan_sleepsite_map/Common Sleep Sites.csv" #this will need to be changd to your folder

g <- st_read(fname , package='sf')
str(g)
g$latlong <- as.character(g$LAT...LONG) #convert to string
g$latitude <- str_sub(g$latlong,1,10) #extract lat
g$longitude <- str_sub(g$latlong,-10,-1) #extract long
g <- g[ , c("WPT.NAME","COMMON.NAMES", "latitude", "longitude" , "ELEV") ] #subset
g <- clean_names(g)#make names better
g$latitude <- parse_lat(g$latitude)#convert to decimal coords
g$longitude <- parse_lon(g$longitude)#convert to decimal coords
g$elev <- as.numeric(str_sub(g$elev,1,3))/3.28084 #convert to meters
g2 <- st_as_sf(g, coords=c("longitude", "latitude"), crs = 4326) 
#project it 



#convert to sf object
sleepsites <- st_as_sf(g, coords=c("longitude", "latitude"), crs = 4326) #convert to sf object

mapview(g2) + mapview(trails)

POIs <- readOGR(dsn = "/Users/BJB/Dropbox/ODD_GPSwork/susan_sleepsite_map/Lomas Barbudal Map POI.GPX", layer="waypoints") 
Phenology <-  readOGR(dsn = "/Users/BJB/Dropbox/ODD_GPSwork/susan_sleepsite_map/Phenology 2015.GDB.GPX", layer="waypoints") 

# Identify shapefiles
working_dir = "~/Dropbox/LOMAS_MAP/QGIS/1.4/shapefiles/" #this could be your local file with lomas map
setwd(working_dir)
shapefiles = list.files(pattern = "shp$", recursive = TRUE) #get all shape files names
str(shapefiles)

trailsshp <- shapefiles[grepl('Trails/', shapefiles, fixed = TRUE)] 
riossshp <- shapefiles[grepl('Rios/', shapefiles, fixed = TRUE)] 
quebsshp <- shapefiles[grepl('Quebradas/', shapefiles, fixed = TRUE)] 
canalshp <- shapefiles[grepl('Canal/', shapefiles, fixed = TRUE)] 
drtrdshp <- shapefiles[grepl('Dirt Roads/', shapefiles, fixed = TRUE)] 
dryquebshp <- shapefiles[grepl('Dry Quebradas/', shapefiles, fixed = TRUE)] 
fenceshp <- shapefiles[grepl('Fences/', shapefiles, fixed = TRUE)] 
majrdsshp <- shapefiles[grepl('Major Roads/', shapefiles, fixed = TRUE)] 
shtctsshp <- shapefiles[grepl('Shortcuts/', shapefiles, fixed = TRUE)] 


#make a spatial object of trails, can do the same for other stuff if desired

for (i in 1:length(trailsshp)){
  shpi <- readOGR(dsn = paste0(working_dir,trailsshp[i])) 
  if(i==1){trails <- shpi}
  if(i>1){trails <- rbind(trails,shpi)}
}

for (i in 1:length(riossshp)){
  shpi <- readOGR(dsn = paste0(working_dir,riossshp[i])) 
  if(i==1){rios <- shpi}
  if(i>1){rios <- rbind(rios,shpi)}
}

for (i in 1:length(quebsshp)){
  shpi <- readOGR(dsn = paste0(working_dir,quebsshp[i])) 
  if(i==1){quebradas <- shpi}
  if(i>1){quebradas <- rbind(quebradas,shpi)}
}

for (i in 1:length(dryquebshp)){
  shpi <- readOGR(dsn = paste0(working_dir,dryquebshp[i]))
  if(i==1){dry_quebradas <- shpi}
  if(i>1){dry_quebradas <- rbind(dry_quebradas,shpi)}
}

for (i in 1:length(fenceshp)){
  shpi <- readOGR(dsn = paste0(working_dir,fenceshp[i])) 
  if(i==1){fences <- shpi}
  if(i>1){fences <- rbind(fences,shpi)}
}

for (i in 1:length(majrdsshp)){
  shpi <- readOGR(dsn = paste0(working_dir,majrdsshp[i])) 
  if(i==1){major_roads <- shpi}
  if(i>1){major_roads <- rbind(major_roads,shpi)}
}

for (i in 1:length(drtrdshp)){
  shpi <- readOGR(dsn = paste0(working_dir,drtrdshp[i])) 
  if(i==1){dirt_roads <- shpi}
  if(i>1){dirt_roads <- rbind(dirt_roads,shpi)}
}

for (i in 1:length(shtctsshp)){
  shpi <- readOGR(dsn = paste0(working_dir,shtctsshp[i])) 
  if(i==1){shortcuts <- shpi}
  if(i>1){shortcuts <- rbind(shortcuts,shpi)}
}


all_shapes <- rbind(trails,rios,quebradas,fences,dry_quebradas,dirt_roads, major_roads)
mapview(all_shapes)
quebsshp
mapview(trails) + mapview(rios) +  mapview(quebradas)


# ##########this is an example from online#########33
# 
# plot(trails)
# grid <- raster(extent(trails))
# res(grid) <- 2
# # Create an empty raster.
# grid <- raster(extent(trails))
# # Choose its resolution. I will use 1 degrees of latitude and longitude.
# res(grid) <- 1
# 
# # Make the grid have the same coordinate reference system (CRS) as the shapefile.
# proj4string(grid)<-proj4string(trails)
# 
# # Transform this raster into a polygon and you will have a grid, but without Brazil (or your own shapefile).
# gridpolygon <- rasterToPolygons(grid)
# 
# # Intersect our grid with Brazil's shape (or your shapefile). R will need a considerable time to do that (~15 minutes in our example). Just let it work while you do other things, or drink a coffee, or whatever. Note that the time needed to finish this depends on the size (area) of your shape, and on your grid resolution. So, don't expect to intersect a 0.5 lat/long grid with a world shapefile in 5 minutes (=]).
# dry.grid <- intersect(dryland, gridpolygon)
# 
# # Plot the intersected shape to see if everything is fine.
# plot(dry.grid)
# 
# 
# #####################try with lomas
# library(sf)
# #https://gis.stackexchange.com/questions/225157/generate-rectangular-fishnet-or-vector-grid-cells-shapefile-in-r
# #https://stackoverflow.com/questions/53789313/creating-an-equal-distance-spatial-grid-in-r/53801517
# # make an object the size and shape of the output you want
#   
#   lomas_bb <- matrix(c(-85.41,  10.55,
#                        -85.35,  10.55,
#                        -85.35, 10.49,
#                        -85.41, 10.49,
#                        -85.41,  10.55), byrow = TRUE, ncol = 2) %>%
#     list() %>% 
#     st_polygon() %>% 
#     st_sfc(., crs = 4326)
# 
# grid_spacing <- 1000  # size of squares, in units of the CRS (i.e. meters for 5514)
# polygony <- st_make_grid(lomas_bb, square = T, cellsize = c(grid_spacing, grid_spacing) ) %>% st_sf()
#  
# mapview(polygony) 
#   # st_sf() # not really required, but makes the grid nicer to work with later
# 
# #click(trails, n=1, id=FALSE, xy=TRUE , show=TRUE)
#bb <- bbox(trails)
#bbb <- bbox2SP(bbox=bb)
# bbbb <- st_as_sf(bbb)
# mapview(bbbb) + mapview(trails)
# plot(bbb)
# grid_spacing <- 1000  # size of squares, in units of the CRS (i.e. meters for 5514)
# polygony <- st_make_grid(bbbb, square = T, cellsize = c(grid_spacing, grid_spacing) ) %>% st_sf()
# mapview(polygony)
# 
# 
# ###below works for lomas but grid size is wrong
# lomas_bb <- matrix(c(-85.41,  10.55,
#                      -85.35,  10.55,
#                      -85.35, 10.49,
#                      -85.41, 10.49,
#                      -85.41,  10.55), byrow = TRUE, ncol = 2) %>%
#   list() %>% 
#   st_polygon() %>% 
#   st_sfc(., crs =  4326)
# 
# lomas_bb2 <- st_transform(lomas_bb, crs= 4326)
# 
# 
# mapview(lomas_bb) + mapview(lomas_bb2 , color="red")
# 
# str(lomas_bb)
# mapview(lomas_bb)
# mapview(lomas_bb2)
# lomas_bb2 <- matrix(c(-85.41,  10.55,
#                      -85.35,  10.55,
#                      -85.35, 10.49,
#                      -85.41, 10.49,
#                      -85.41,  10.55), byrow = TRUE, ncol = 2) %>%
#   list() %>% 
#   st_polygon() %>% 
#   st_sfc(., crs =  5514)
# 
# mapview(lomas_bb2)
# st_transform(5514)
# 
# 
# 
# str(lomas_bb)
# polygony<- st_make_grid(lomas_bb , n = c(20, 20), crs =  4326, what = 'polygons') %>%
#   st_sf('geometry' = ., data.frame('ID' = 1:length(.)))
# 
# polygony2 <- st_make_grid(lomas_bb2 , n = c(20, 20), crs =  4326, what = 'polygons') %>%
#   st_sf('geometry' = ., data.frame('ID' = 1:length(.)))
# 
# str(all_shapes)
# polygony3 <- st_make_grid(all_shapes, square = T, cellsize = c(1000, 1000)) %>% # the grid, covering bounding box
#   st_sf() 
# 
# str(lomas_bb)
# 
# mapview(polygony , alpha.regions = 0.1 , color="yellow" , lwd=2) + mapview(polygony2 , alpha.regions = 0.1 , color="orange")  +  mapview(trails , color="blue") + mapview(g2, color="red" , cex=3)
# 
# lomas_bb

#######brendans attempt

# grid_shapes <- rbind(trails,rios,quebradas,fences,dry_quebradas,dirt_roads)
# mapview(grid_shapes)

# bbbb <- st_as_sf(grid_shapes)
# 
# gridtest <- st_make_grid(bbbb, square = T, cellsize = c(1000, 1000) ) %>% st_sf() 
# 
# gridtest2 <- st_make_grid(bbbb, square = T, cellsize = c(1000, 1000) ) %>% st_sf() 
# 
# mapview(gridtest)
# grid_500m <- st_make_grid(e2b, square = T, cellsize = c(500, 500) ) %>% 
#   st_sf() 
# mapview(grid_500m)
# 
# grid_100m <- st_make_grid(gridtest, square = T, cellsize = c(100, 100) ) %>% 
#   st_sf() 
# 
# grid_50m <- st_make_grid(gridtest, square = T, cellsize = c(50, 50)) %>% # the grid, covering bounding box
#   st_sf() # not really required, but makes the grid nicer to work with later


##########new way from Kate#######3
#maybe use gridshapes
grid_shapes <- rbind(trails,rios,quebradas,fences,dry_quebradas,dirt_roads)
mapview(grid_shapes)

e <- as(raster::extent(min(POIs@coords[,1]), max(POIs@coords[,1]), min(POIs@coords[,2]), max(POIs@coords[,2])), "SpatialPolygons")
proj4string(e) <- crs(POIs)
e3 <- spTransform(e, CRS("+init=EPSG:32616"))
ebuf <- buffer(e3, width = 200) #add 200 m buffer
e2 <- st_as_sf(e)
e2b <- st_as_sf(ebuf)

grid_100m <- st_make_grid(e2b, square = T, cellsize = c(100, 100) ) %>% 
  st_sf() 

grid_50m <- st_make_grid(e2b, square = T, cellsize = c(50, 50)) %>% # the grid, covering bounding box
  st_sf() # not really required, but makes the grid nicer to work with later


#mapview(grid_500m , alpha.regions = 0.05 , color="yellow" , lwd=0.5 , col.regions="yellow") +  mapview(trails , color="blue") + mapview(sleepsites, color="pink" , col.regions="pink" , cex=3 , alpha.regions="red") +  mapview(major_roads , color="grey") + mapview(dirt_roads , color="brown") + mapview(fences , color="black") +  mapview(rios , color="blue" , lty=3) +  mapview(quebradas , color="lightblue")
 
mapview(grid_100m , alpha.regions = 0.01 , color="yellow" , lwd=1 , col.regions="yellow") + mapview(grid_50m , alpha.regions = 0.01 , color="orange", col.regions="orange" , burst=FALSE)  + mapview(trails , color="red") +  mapview(major_roads , color="grey") + mapview(dirt_roads , color="brown") + mapview(fences , color="black") +  mapview(rios , color="darkblue" , lty=3) +  mapview(quebradas , color="blue") + mapview(dry_quebradas , color="lightblue" , lw=0.5) + mapview(sleepsites, color="violet" , col.regions="violet" , cex=3 ) + mapview(POIs , color="purple", col.regions="purple" , cex=3) +  mapview(shortcuts , color="red") + mapview(Phenology , color="green", col.regions="green" , cex=3 )  
 
mapview(grid_100m , alpha.regions = 0.01 , color="yellow" , lwd=1 , col.regions="yellow") + mapview(grid_50m , alpha.regions = 0.01 , color="orange", col.regions="orange" , burst=TRUE)  + mapview(trails , color="red")
 
#https://gis.stackexchange.com/questions/206929/r-create-a-boundingbox-convert-to-polygon-class-and-plot/206952
#make sp polygon or vector 
max(POIs@coords[1,])
coords1 <- cbind(c(2, 4, 4, 1, 2), c(2, 3, 5, 4, 2))
sp

e <- as(raster::extent(min(POIs@coords[,1]), max(POIs@coords[,1]), min(POIs@coords[,2]), max(POIs@coords[,2])), "SpatialPolygons")
proj4string(e) <- crs(POIs)
e3 <- spTransform(e, CRS("+init=EPSG:32616"))
ebuf <- buffer(e3, width = 200)
e2 <- st_as_sf(e)
e2b <- st_as_sf(ebuf)

grid_500m <- st_make_grid(e2b, square = T, cellsize = c(500, 500) ) %>% 
  st_sf() 

st_geometry(e2b)
str(e3)
mapview(e2) + mapview(grid_500m)
str(grid_100m)
crs(grid_500m)
