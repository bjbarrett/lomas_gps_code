trackpts_test <- function(x){ 
  print("DIAGNOSTICS OF FILE")
  print("unique tracks")
  print(length(unique(x$track_fid)))
  print("________________________________________")
  print("INSPECT INDIVIDUAL TRACKPOINTS")
  for(i in 1:max(x$track_fid)){
    print(unique((x$name[x$track_fid==i]))) #number of unique tracks
    print(
      max(as_datetime(x$time[x$track_fid==i]) ) - min(as_datetime(x$time[x$track_fid==i])) 
        )#duration of each track
    
    ifelse(
      as_date(str_sub(unique(x$name[x$track_fid==i]),1,10)) == min(as_date(x$time[x$track_fid==i])) , print("min date and name match") , print("INSPECT: min date and name of track don't match")
      ) #there is this time zone issue, but should bypass it in most cases unless we picked up minkeys after 00:00 GMT
    
    ifelse( 
      (max(x$track_seg_point_id[x$track_fid==1]) + 1) == length(unique(x$track_seg_point_id[x$track_fid==1])) , "" , "WARNING: TRACK SEG POINT IDS ARE MISSING INTEGERS, RENAME STARTING AT ZERO"
    )#shows that the track_seg_point IDS have some missing integers, may not be necessary
    
    print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
  }
}

###trackpts_test(x) #x is the name of the trackpoints files
###you can do something similar for waypoints (namely making sure the date matches name, adjusting for GMT)