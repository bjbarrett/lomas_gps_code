library(mapview)
library(sf) ###using sf and maptools to visualize data https://geocompr.github.io/geocompkg/articles/gps-tracks.html
library(rgdal)#write ogr
library(lubridate) #useful for dealing with times ina more intuitive manner here is a cheat sheet https://evoldyn.gitlab.io/evomics-2018/ref-sheets/R_lubridate.pdf

###using map tools https://stackoverflow.com/questions/6397523/read-multiple-gpx-files to read GPS files


#alternatively you can set working directory instead of navigate to long folder path
setwd("/Users/BJB/Desktop/Lomas_GPS_Subset/201501") #sets WD to where files are, needs to be changed to your computer

#################################################################
########CLEANING GPX DATA and writing to new GPX FILES###########
#################################################################

filename <- "0115 FL.gpx" #assuming this is loaded in wd otherwise use a folder directory or URL
######RGDAL to load
trkpt <- readOGR(dsn = filename, layer="track_points") #using this function in RGDAL
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
length(unique(trkpt_clean$track_seg_point_id))

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
#####load files
filename <- "/Users/BJB/Desktop/Lomas_GPS_Subset/201501/MK2010_2012.gpx" #read file
trkpts <- readOGR(dsn = filename, layer="track_points") #using this function in RGDAL
trx <- readOGR(dsn = filename, layer="tracks") #using this function in RGDAL
unique(trkpts$time)#ony 149 timesteps

##visualize raw data and investigate some properties
mapview(trx , zcol="name")#visualize all tracks
mapview(trkpts , zcol="track_fid")#visualize all trkpts
str(trkpts) #tr_fid has unique ID for each track
#####Note only one of these days on trkpts has an actual timestamp

length(unique(trkpts$track_fid))#unique tracks_fid
str(trx)

##extract track names, lets inspect for cleaning

track_names <- toupper(as.vector(trx$name)) #vector of name of tracks in tracks file uppercased
track_names#view and lets correct visible errors
#https://stackoverflow.com/questions/7963898/extracting-the-last-n-characters-from-a-string-in-r
library(stringr) #useful package
nchar(track_names) #shows lenth of string with names in it, helps to identify aberations
#this is easy-- names 1,2, and 66 but we can identify this via code as well via which or using logical commands
track_names <- str_replace(track_names, "AEZ160211", "EZ160211") #one way, but can also vectorize for multipl entries
track_names[2] <- "MKDD0810" ##note we cant tell from this is its august 10th in some year or august 2010, need to go back and look at folders to check

#before we replace next one, i notice there is a repeat of the day, lets visualize it (also can compare GPS coords or number of points)
which(track_names=="MK250312 001")#gives slot in vector with this name
which(track_names=="MK250312")#gives slot in vector with this name

temp1 <- trkpts[trkpts$track_fid==which(track_names=="MK250312 001")-1,]
temp2 <- trkpts[trkpts$track_fid==which(track_names=="MK250312")-1,]

mapview(temp1 , map.types="Esri.WorldImagery" , alpha=0.5 , col.regions="orange") + mapview(temp2 ,map.types="Esri.WorldImagery" , alpha=0.5 , col.regions="slateblue" ) #plots two trackpoints with same date 

max(temp1$track_seg_point_id)
max(temp2$track_seg_point_id) #this has more points. lets pretend it is right and delete old one (but at end of workflow) later on
# trkptsn <- trkpts[trkpts$track_fid!=which(track_names=="MK250312 001")-1,]#code to delete duplicate// wait for end to do it so i do not have to do the same tracks in the meantime

track_names <-  str_replace(track_names, "MK250312 001", "XXXXXXXX") #placeholder for now
range(nchar(track_names))#make sure all the same length

#we can extract relevant info from files to automajically rename everything

year_2 <-str_sub(track_names,-2,-1)##extracts last two charachters (hypothetical year if files consistently named)
group_2 <- str_sub(track_names,1,2)##extracts first two charachters (hypothetical group if files consistently named)
month_2 <- str_sub(track_names,-4,-3)
day_2 <- str_sub(track_names,3,4)
year_4 <- paste(20,year_2, sep = "") #add 20 to year_2

track_names_new <- paste(year_4, month_2 , day_2, group_2, sep = "_")#new track names!! lets deal with EZ
track_names_new[1] <- "2011_02_16_MK_EZ"

#lets put new tracknames into track points file
trkpts$name <- as.character(trkpts$name) ##convert colum to charachter from factor to populate
trkpts$name <-track_names_new

#attach new names to trackpoints
for(i in min(trkpts$track_fid):max(trkpts$track_fid) ){
  l <- length(trkpts$name[trkpts$track_fid==i])
  trkpts$name[trkpts$track_fid==i] <- rep(track_names_new[i+1],l) #i + 1 b/c starts at 0
}

#in theory, now we can get ready to start cleaning the file
trx$number <- 0:(nrow(trx)-1) #assign same track_id starting at 0 to trx$name

for(i in 0:66){
 print( mapview(trkpts[trkpts$track_fid==i,] , map.types="Esri.WorldImagery") + mapview(trx[trx$number==i,]))
} #this visualizes all the tracks, need one where we have more informative info on map

#mapview(trkpts[trkpts$track_fid==i,] , map.types="Esri.WorldImagery"  , z.col=trkpts$track_seg_point_id[trkpts$track_fid==i])

mapview( trkpts[trkpts$track_fid==1,] )
mapview(trx[trx$number==i,])
mapview(trx)
mapview(trx@lines[[1]])
str(trx)
#####################GENERAL SPATIAL OBJECT COMMANDS############
st_layers("0115 AA.gpx") #shows layers of objects in this file
st_layers("0115 FL.gpx") #shows layers of objects in this file
st_layers("0115 SP.gpx") #shows layers of objects in this file

trx = st_read("0115 AA.gpx", layer = "tracks")#loads just tracks of file
trxpts = st_read("0115 AA.gpx", layer = "track_points")#loads just tracks of file
plot(trx)
plot(trxpts)

str(trx)
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

trx$geometry[[1]][[1]][2,]

trkpts$track_seg_point_id
trkpts$track_seg_point_id
str(trkpts$geometry)
str(trx)
trx$geometry[[3]][[1]]
trx$name
trx$geometry[[1]][[1]]
trkpts$geometry[[1]][1:2]
trkpts$geometry[1:4][1:2]
max(trkpts$track_fid) #gives a track ID
#########this is another way to load a gpx file i just saw that stores it in a different format
library(plotKML)
x <- readGPX("/Users/BJB/Desktop/Lomas_GPS_Subset/201501/0115 FL.gpx" , metadata = TRUE, bounds = TRUE, 
        waypoints = TRUE, tracks = TRUE, routes = TRUE)
summary(x)
mapview(x$tracks)
# readGPS(i = "garmin", f = "/Users/BJB/Desktop/Lomas_GPS_Subset/201501/0115 FL.gpx", type="w", invisible=TRUE) #this is how you use radGPS if you have GPSBabel installed
# this website contains a package and functions for writing GPX files from a dataframe https://rdrr.io/cran/pgirmess/man/writeGPX.html