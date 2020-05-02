# install.packages("mapview")
# install.packages("sf")
library(mapview)
library(sf)
library(rgdal)#write ogr
library(lubridate) #useful for dealing with times ina more intuitive manner here is a cheat sheet https://evoldyn.gitlab.io/evomics-2018/ref-sheets/R_lubridate.pdf

###using map tools https://stackoverflow.com/questions/6397523/read-multiple-gpx-files to read GPD siles
########using sf and maptools to visualize data
#https://geocompr.github.io/geocompkg/articles/gps-tracks.html

#alternatively you can set working directory instead of navigate to long folder path
setwd("/Users/BJB/Desktop/Lomas_GPS_Subset/201501") #sets WD to where files are

#################################################################
########CLEANING GPX DATA and writing to new GPX FILES###########
#################################################################

filename <- "0115 FL.gpx" #assuming this isloaded in wd otherwise use a folder directory or URL
######RGDAL
trkpt <- readOGR(dsn = "/Users/BJB/Desktop/Lomas_GPS_Subset/201501/0115 FL.gpx", layer="track_points") #using this function in RGDAL
trk <- readOGR(dsn = filename, layer="tracks") #using this function in RGDAL
wpt = readOGR(dsn = filename, layer="waypoints") #using this function in RGDAL

#look at tracks and examine dimensions. these commands are useful for troubleshooting and exploring object
str(trk)
trk$name #names of track
mapview(trk) #helps us look at track, we can toggle basemap

#look at track points and lets try to remove erroneous points
str(trkpt) #examine object
mapview(trkpt , cex=0.8) + mapview(trk) #this plots track points and tracks but makes points smaller using cex command
range(trkpt$track_seg_point_id) #range unique track point IDS
length(unique(trkpt$track_seg_point_id)) #number of uniqur track point IDS

###manipulating times in this GPS package can be useful for quarrantining (HA HA) problems and mucking with stuff
range(date(trkpt$time)) #gives min and max of date to identify problems
unique(date(trkpt$time)) #gives unique dates on the track points, note that there are multiple days in this
range(as_datetime(trkpt$time))
max(as_datetime(trkpt$time) ) - min(as_datetime(trkpt$time) ) #time differnce between min and max in file

#remove early points where GPS is trying to get a good signal
trkpt2 <- trkpt[trkpt$track_seg_point_id >1,] #doing by seg point can also do by date and time using lubridate package
mapview(trkpt2 , cex=2)
range(trkpt2$track_seg_point_id)
length(unique(trkpt2$track_seg_point_id))

#remove middle points where person went to meet Brendan or Buddy to get Panama fruits
trkpt_clean <- trkpt2[trkpt2$track_seg_point_id > 915 | trkpt2$track_seg_point_id < 888 ,] 
mapview(list(trkpt,trkpt_clean) , map.types="Esri.WorldImagery" , alpha=0)#compare multiple objects, making this 2 colors would be good

#advanced mapview https://r-spatial.github.io/mapview/articles/articles/mapview_02-advanced.html
mapview(trkpt , map.types="Esri.WorldImagery" , alpha=0 , col.regions="slateblue" ) + mapview(trkpt_clean , map.types="Esri.WorldImagery" , alpha=0 , col.regions="orange")


############lets do this in tracks as well, although its likely not necessary######
# ###this section is in progress
# str(trk)
# trk$geometry
# #mess around with dimensions
# trk$geometry[[1]][[1]][[1]]
# trk$geometry[[1]]
# trk$geometry[[1]][[1]]
# length(trk$geometry[[1]][[1]][,1])
# trk$geometry[[1]][[1]][1:4,] #this gives is the lat long elements by row. we can use row index like above to remove erroneous points
# trk_clean <- trk$geometry[[1]][[1]][2:887,] #this is wrong, need to figure out indexing notation
# #google subset a track in sf or rgdal
# mapview(trk)

#######write to gpx file, i can do wthis with rgdal it is unclear about sf for .gpx

#http://zevross.com/blog/2016/01/13/tips-for-reading-spatial-files-into-r-with-rgdal/
#https://gis.stackexchange.com/questions/190687/create-gpx-track-in-r-writeogr-function
#sf write for other types of databases

writeOGR(trkpt_clean, driver="GPX", layer= "track_points",  dsn="/Users/BJB/Desktop/Lomas_GPS_Subset/201501/2015_01_FL_trackpoints_clean.gpx" , dataset_options = "GPX_USE_EXTENSIONS=yes" , overwrite_layer = TRUE) #be cautious about using overwrite layer. i turned this on for troubleshootomg

writeOGR(wpt , driver="GPX", layer="waypoints",  dsn="/Users/BJB/Desktop/Lomas_GPS_Subset/201501/2015_01_FL waypoints_clean.gpx" , dataset_options = "GPX_USE_EXTENSIONS=yes" , overwrite_layer = TRUE)

max(as_datetime(trkpt_clean$time) ) - min(as_datetime(trkpt_clean$time) ) #time differnce between min and max in cleaned file

#########streamlined workflow

trkpt <- readOGR(dsn = "/Users/BJB/Desktop/Lomas_GPS_Subset/201501/0115 FL.gpx", layer="track_points") #read datausing this function in RGDAL
trkpt_clean <- trkpt[trkpt$track_seg_point_id >1 & trkpt$track_seg_point_id > 915 | trkpt$track_seg_point_id < 888 ,] 
mapview(trkpt , map.types="Esri.WorldImagery" , alpha=0 , col.regions="slateblue" ) + mapview(trkpt_clean , map.types="Esri.WorldImagery" , alpha=0 , col.regions="orange")
writeOGR(trkpt_clean, driver="GPX", layer=c("waypoints", "track_points"),  dsn="/Users/BJB/Desktop/Lomas_GPS_Subset/201501/2015_01_FL_trackpoints_clean.gpx" , dataset_options = "GPX_USE_EXTENSIONS=yes" , overwrite_layer = TRUE) #be cautious about using overwrite layer. i turnd this on for troubleshootomg

#########################exercises for odd#######################

#1) clean up above track by using timestamps instead of track segment point ids
#2) truncate the the end of dataset by removing all tracking points taken after the sleepsite point was entered
#3) renmame the sleepsite  waypoint extracted from this Flakes GPS file  to 2015_01_22_SLP_FL
#4) if you really want to be fancy figure out how to affix calculate velocity and graph a heatplot of speed

###########ODDS CLEANED MK DATA#######
st_layers("MK2010_2012.gpx") #shows layers of objects in this file

filename <- "/Users/BJB/Desktop/Lomas_GPS_Subset/201501/MK2010_2012.gpx"
trkpts <- readOGR(dsn = filename, layer="track_points") #using this function in RGDAL
trx <- readOGR(dsn = filename, layer="tracks") #using this function in RGDAL
trx = st_read(filename, layer = "tracks")#loads just tracks of file
trkpts = st_read(filename, layer = "track_points")#loads just tracks of file

str(trx)
mapview(trx)
plot(trx$geometry) #plot tracks in line
plot(trx)
mapview(trkpts , cex=2)
plot(trkpts$geometry ) #plot traclpoints
plot(trkpts)


#####################GENERAL SPATIAL OBJECT COMMANDS############
st_layers("0115 AA.gpx") #shows layers of objects in this file
st_layers("0115 FL.gpx") #shows layers of objects in this file
st_layers("0115 SP.gpx") #shows layers of objects in this file

trx = st_read("0115 AA.gpx", layer = "tracks")#loads just tracks of file
trxpts = st_read("0115 AA.gpx", layer = "track_points")#loads just tracks of file

class(trx)#see what file contains and inspect elements
class(trxpts)
st_geometry_type(trx)
nrow(trx)

plot(trx$geometry) #plot tracks in line
plot(trxpts$geometry) #plot trxpoints

class(trx$desc) #this offers descriptions in file, i dont think we have this on the subset of data i looked at
as.character(trxpts$desc)

###########lets visualize data###############
filename <- "0115 AA.gpx"
# filename <- "0115 SP.gpx"
# filename <- "0115 FL.gpx"
######RGDAL

########sf fcns
trk = read_sf(filename, layer = "tracks") #extract tracks if sf
trkpt = read_sf(filename, layer = "track_points") #extract track points in sf
wpt = read_sf(filename , layer = "waypoints") #extract waypoints in sf

plot(trkpt) #useful for more detailed info, can be converted into tracks
plot(trk) #usefult for visualizing days/seperate tracks on file

str(trk)
str(trkpt)

trkpt$geometry[1:4] #can look at lat long objects, finding these indexes might be useful for editing
summary(trkpt$time) #summary of time files
trkpt$time #view timesteps of each file

plot(trkpt$time, 1:nrow(trkpt)) #plot sampling rate
difftime(trkpt$time[11], trkpt$time[10])##gives sampling rate between points
#view in mapview (works on rgdal and sf)
mapview(trkpt)
mapview(trk)


#########this is another way to load a gpx file i just saw that stores it in a different format
library(plotKML)
x <- readGPX("/Users/BJB/Desktop/Lomas_GPS_Subset/201501/0115 FL.gpx" , metadata = TRUE, bounds = TRUE, 
        waypoints = TRUE, tracks = TRUE, routes = TRUE)
summary(x)
mapview(x$tracks)
# readGPS(i = "garmin", f = "/Users/BJB/Desktop/Lomas_GPS_Subset/201501/0115 FL.gpx", type="w", invisible=TRUE) #this is how you use radGPS if you have GPSBabel installed
# this website contains a package and functions for writing GPX files from a dataframe https://rdrr.io/cran/pgirmess/man/writeGPX.html