##    movementString = userId + "\t" + name + "\t" + time2 + "\t" + dur + "\t" + dist + "\t" + speed + "\t" + lat1 + "\t" + lon1 + "\t" + lat2 + "\t" + lon2 + "\n";

fullData <- scan("D:/Andrei/movement_analysis/movement_dup_n_uniqs/distributedReader.2.1.twitterCrawler01.2017.12.merged.uniqueLoc.movement.out", sep="\t", quote="",  what=list(NULL, NULL,  NULL, numeric(), numeric(), numeric(),NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))  #duration, distance, speed


fullData_dup <- scan("D:/Andrei/movement_analysis/movement_dup_n_uniqs/distributedReader.2.1.twitterCrawler01.2017.12.merged.dupLoc.movement.out", sep="\t", quote="",  what=list(NULL, NULL,  NULL, numeric(), numeric(), numeric(),NULL, NULL, NULL, NULL))  #duration, distance, speed /new file from parser 1.3
fullData_un <- scan("D:/Andrei/movement_analysis/movement_dup_n_uniqs/distributedReader.2.1.twitterCrawler01.2017.12.merged.uniqueLoc.movement.out", sep="\t", quote="",  what=list(NULL, NULL,  NULL, numeric(), numeric(), numeric(),NULL, NULL, NULL, NULL))  #duration, distance, speed /new file from parser 1.3
fullData_all <- scan("D:/Andrei/movement_analysis/initial_movement/distributedReader.2.1.twitterCrawler01.2017.12.merged.movementOnly.out", sep="\t", quote="",  what=list(NULL, NULL,  NULL, numeric(), numeric(), numeric(),NULL, NULL, NULL, NULL))  #duration, distance, speed /new file from parser 1.3



selectedDataList <- list (duration = fullData[[4]], distance = fullData[[5]], speed = fullData[[6]])
selectedDataList_un <- list (duration = fullData_un[[4]], distance = fullData_un[[5]], speed = fullData_un[[6]])
selectedDataList_all <- list (duration = fullData_all[[4]], distance = fullData_all[[5]], speed = fullData_all[[6]])


selectedDataFrame <- as.data.frame(selectedDataList)

selectedDataFrame_un <- as.data.frame(selectedDataList_un)
selectedDataFrame_all <- as.data.frame(selectedDataList_all)

#filteredData <- selectedDataList[which(selectedDataList$duration > 0 & is.finite(selectedDataList$speed)) & is.finite(selectedDataList$distance)),] #no neg durations, speed, no Nan no Inf
filteredData <- selectedDataFrame[which(selectedDataFrame$duration > 0),]  #no neg durations, speed, no Nan no Inf

filteredData_un <- selectedDataFrame_un[which(selectedDataFrame_un$duration > 0),]  #no neg durations, speed, no Nan no Inf
filteredData_all <- selectedDataFrame_all[which(selectedDataFrame_all$duration > 0),]  #no neg durations, speed, no Nan no Inf

# calculate log for each column
filteredData$distance_log = log(filteredData$distance+1)
filteredData$speed_log = log(filteredData$speed+1) 
filteredData$duration_log = log(filteredData$duration) 

# calculate log for each column unique
filteredData_un$distance_log = log(filteredData_un$distance+1)
filteredData_un$speed_log = log(filteredData_un$speed+1) 
filteredData_un$duration_log = log(filteredData_un$duration) 

# calculate log for each column all
filteredData_all$distance_log = log(filteredData_all$distance+1)
filteredData_all$speed_log = log(filteredData_all$speed+1) 
filteredData_all$duration_log = log(filteredData_all$duration) 

################################################################

#calculate max values
distance_log_max = max(filteredData$distance_log)
speed_log_max = max(filteredData$speed_log)
duration_log_max = max(filteredData$duration_log)

#calculate max values all
distance_log_max = max(filteredData_all$distance_log)
speed_log_max = max(filteredData_all$speed_log)
duration_log_max = max(filteredData_all$duration_log)


# number of cells horizontalli and vertically
nBins<-100

# bin records into heatmap cells for SPEED and DURATION ####################################################################### 
binsx <- seq(0, duration_log_max, length=nBins)
binsy <- seq(0, speed_log_max, length=nBins)

freq2D <- diag(nBins)*0

numRec <- nrow(filteredData)

for (i in 1:numRec) {

	dur_log		<- filteredData$duration_log[i];
	speed_log 	<- filteredData$speed_log[i];
	
	if (dur_log && speed_log ) {

		# 
		xBin <- findInterval(dur_log, binsx);
		yBin <- findInterval(speed_log, binsy);
		

		freq2D[xBin, yBin] <- freq2D[xBin, yBin] + 1;
	}
}

# bin records into heatmap cells for SPEED AND DISTANCE ####################################################################### 
binsx <- seq(0, distance_log_max, length=nBins)
binsy <- seq(0, speed_log_max, length=nBins)

freq2D <- diag(nBins)*0

numRec <- nrow(filteredData)

for (i in 1:numRec) {

	distance_log	<- filteredData$distance_log[i];
	speed_log 		<- filteredData$speed_log[i];
	
	if (distance_log && speed_log ) {

		# 
		xBin <- findInterval(distance_log, binsx);
		yBin <- findInterval(speed_log, binsy);
		

		freq2D[xBin, yBin] <- freq2D[xBin, yBin] + 1;
	}
}

# bin records into heatmap cells for  DURATION AND DISTANCE ####################################################################### 
binsx <- seq(0, distance_log_max, length=nBins)
binsy <- seq(0, duration_log_max, length=nBins)

freq2D <- diag(nBins)*0

numRec <- nrow(filteredData)

for (i in 1:numRec) {

	distance_log	<- filteredData$distance_log[i];
	duration_log 	<- filteredData$duration_log[i];
	
	if (distance_log && duration_log ) {

		# 
		xBin <- findInterval(distance_log, binsx);
		yBin <- findInterval(duration_log, binsy);
		

		freq2D[xBin, yBin] <- freq2D[xBin, yBin] + 1;
	}
}

####################################################################################################################################################################################



# bin records for user heterogeniety: unique user to movemet record count; uniuque user count using DURATION AND DISTANCE as axes ####################################################################### 
binsx <- seq(0, distance_log_max, length=nBins)
binsy <- seq(0, duration_log_max, length=nBins)

#reading existing 100x100 matrix of unique users
unique_users <- scan('C:/Users/a_k257/Documents/GitHub/speedProcessing/r/heterogeneity_heatmap/unique_users.txt') 
unique_user_matrix <- matrix(unique_users,nrow = 100,ncol = 100, byrow = TRUE)

#reading existing 100x100 matrix of unique users to movement records ratio
ratio <- scan('C:/Users/a_k257/Documents/GitHub/speedProcessing/r/heterogeneity_heatmap/rec_per_user_ratio.txt')
ratio_matrix <- matrix(ratio,nrow = 100,ncol = 100, byrow = TRUE)



#####################################################################################################################################

# bin records for unique and duplicate files using DURATION AND DISTANCE as axes ####################################################################### 
binsx <- seq(0, distance_log_max, length=nBins)
binsy <- seq(0, duration_log_max, length=nBins)

freq2D_un <- diag(nBins)*0
freq2D_dup <- diag(nBins)*0

numRec_un <- nrow(filteredData_un)
numRec_dup <- nrow(filteredData)

for (i in 1:numRec_un) {
  
  distance_log	<- filteredData_un$distance_log[i];
  duration_log 	<- filteredData_un$duration_log[i];
  
  if (distance_log && duration_log ) {
    
    # 
    xBin <- findInterval(distance_log, binsx);
    yBin <- findInterval(duration_log, binsy);
    
    
    freq2D_un[xBin, yBin] <- freq2D_un[xBin, yBin] + 1;
  }
}

for (i in 1:numRec_dup) {
  
  distance_log	<- filteredData$distance_log[i];
  duration_log 	<- filteredData$duration_log[i];
  
  if (distance_log && duration_log ) {
    
    # 
    xBin <- findInterval(distance_log, binsx);
    yBin <- findInterval(duration_log, binsy);
    
    
    freq2D_dup[xBin, yBin] <- freq2D_dup[xBin, yBin] + 1;
  }
}

## calculate matrix difference
freq2D_diff <- freq2D_dup - freq2D_un

#####################################################################################################################################



# histogram 
raw_hist <- hist(freq2D[freq2D > 0], 100)

raw_hist <- hist(freq2D_diff[freq2D_diff > 0], 100)

#use log scale for histogram counts
log_hist <-raw_hist
raw_counts <- log_hist[['counts']]
log_counts <- log(raw_counts+1)
log_hist[['counts']] = log_counts
plot(log_hist)

# histogram of log (counts) 
log_freq2D <- log(freq2D+1)
h <- hist(log_freq2D[log_freq2D > 0], 100 )

#add normal distribution line
g <- log_freq2D[log_freq2D > 0]
xfit <- seq(min(g), max(g), length = 100) 
yfit <- dnorm(xfit, mean = mean(g), sd = sd(g)) 
yfit <- yfit * diff(h$mids[1:2]) * length(g) 

lines(xfit, yfit, col = "red", lwd = 2)

# go to excell and calculate breaks

# plot heatmap #####################################################################################################################################################################


# add zero because r needs outside borders;  break = 0.5sd central break centered on the mean; 

 # class_breaks <- c(0,0.01738625,0.88391575,1.75044525,2.61697475,3.48350425,4.35003375,5.21656325,6.08309275,6.94962225,7.81615175,8.68268125,9.54921075,10.41574025, 11.28226975) # SPEED-DURATION sd = 1.733059  mean = 5.649828 max = 11.06507
 # x <- c(0,4.094344562,8.188689124,8.881836305,11.36674295,13.3126531,14.78173366,17.26664031); # duration 1 sec, min, hr, 2hr, day, week, month, year
 # y <- c(1.386294361, 3.258096538, 4.262679877, 6.311734809,10.04329297,16.11809575); # speed  walk 3 mph, car 25 mph, car max 70 mph, ariplane 550 mph, 23k mph, 10 m  mph
 # title = "SPEED-DURATION"

# class_breaks <- c(0,0.3271875,1.2229525,2.1187175,3.0144825,3.9102475,4.8060125,5.7017775,6.5975425,7.4933075,8.3890725,9.2848375,10.1806025,11.0763675) # SPEED AND DISTANCE sd = 1.79153  mean = 5.253895 max = 12.25384
# x <- c(0.34657359, 0.693147181, 1.386294361, 2.079441542, 2.772588722, 3.465735903, 4.158883083, 4.852030264, 5.545177444, 6.238324625, 6.931471806, 7.624618986, 8.317766167, 9.010913347)#c(0.000189376,0.018762282,0.055262696,0.173443934,0.693147181,2.397895273,4.615120517,6.216606101,6.908754779,8.517393171,9.21044036); #distance foot, 100 feet, 300 feet, 1000 feet, mile, 10 miles, 100 miles, 500 miles, 1000 miles, 5000 miles, 10000 miles
# y <- c(1.386294361, 3.258096538, 4.262679877, 6.311734809,10.04329297,16.11809575); # speed  walk 3 mph, car 25 mph, car max 70 mph, ariplane 550 mph, 23k mph, 10 m  mph
# title = "SPEED-DISTANCE"

class_breaks <- c(0,1.040024,1.834502,2.62898,3.423458,4.217936,5.012414,5.806892,6.60137,7.395848,8.190326,8.984804,9.779282) # duration-distance sd = 1.588956  mean = 5.409653 max = 9.134647
x <- c(0.34657359, 0.693147181, 1.386294361, 2.079441542, 2.772588722, 3.465735903, 4.158883083, 4.852030264, 5.545177444, 6.238324625, 6.931471806, 7.624618986, 8.317766167, 9.010913347) #c(0.000189376,0.018762282,0.055262696,0.173443934,0.693147181,2.397895273,4.615120517,6.216606101,6.908754779,8.517393171,9.21044036); #distance foot, 100 feet, 300 feet, 1000 feet, mile, 10 miles, 100 miles, 500 miles, 1000 miles, 5000 miles, 10000 miles
y <- c(0,4.094344562,8.188689124,8.881836305,11.36674295,13.3126531,14.78173366,17.26664031); # duration 1 sec, min, hr, 2hr, day, week, month, year
title = "DURATION-DISTANCE"

##############################################
# class breaks for  other heatmaps           #
##############################################

#difference matrix
raw_breaks <- c(-9100,-4400,-2100,-1000,-500,-0.9,0.9,500,1000,2100,4400,9100) ## geometric series starting 500 with base of 2.063

#heterogeneity matrix — unique users 
raw_breaks <- c(0.9,300,1110,4110,15200,55000) ## geometric series starting 300 with base of 3.7
raw_breaks <- c(0.9,100,490,2400,11800,55000) ## geometric series starting 100 with base of 4.9
raw_breaks <- c(0,0.9,100,170,290,490,835,1420,2415,4100,7000,11900,20200,34300,55000) ## geometric series starting 100 with base of 1.7

#heterogeneity matrix — movement rec per unique user  ratio 
raw_breaks <- c(0.9,10,30,80,220,600) ## geometric series starting 10 with base of ...
raw_breaks <- c(0.9,2,8,35,150,600) ## geometric series starting 2 with base of 4.2
raw_breaks <- c(0,0.9,2,3.2,5.2,8.,13,22,35,56,90,145,235,380,600) ## geometric series starting 2 with base of 1.61
#################################################

raw_breaks <- exp(class_breaks)

# set the first break to 0; make sure 1 is included into second bin
raw_breaks[1]=0
raw_breaks[2]=0.9

#go to color picker for data and pick colors http://tristen.ca/hcl-picker/
# first color is grey for background

# class_colors <- c("#CDCDCD","#F9E8FB","#E4D5F6","#CFC3F0","#BAB2E7","#A5A1DD","#9191D1","#7D80C4","#6A71B6","#5862A6","#475395","#364582","#27376F","#192A5B") # SPEED AND DURATION
# class_colors <- c("#CDCDCD","#F9E8FB","#E2D4F6","#CBC0EE","#B4ADE5","#9E9BD9","#8889CC","#7378BD","#5F67AC","#4B5799","#394786","#283871","#192A5B") #  SPEED AND DISTANCE
 class_colors <- c("#CDCDCD","#F9E8FB","#E0D2F5","#C6BCEC","#ADA8E1","#9594D4","#7D80C4","#676EB3","#515C9F","#3D4A8A","#2A3A73","#192A5B")  #    DURATION AND DISTANCE

####################################
# class colors for other  heatmap #
####################################
#difference matrix
class_colors <- c("#67001f","#b2182b","#d6604d","#f4a582","#fddbc7","#f7f7f7","#d1e5f0","#92c5de","#4393c3","#2166ac","#053061")  #    DURATION AND DISTANCE","################################################

#heterogeneity matrix — unique users 
class_colors <- c("#f0f9e8","#bae4bc","#7bccc4","#43a2ca","#0868ac") #sequential&scheme=GnBu&n=5
class_colors <- c("#CDCDCD","#F2FBB9","#D9EAA2","#C0D98C","#A9C878","#93B665","#7EA554","#6A9444","#588235","#477128","#37601C","#295012","#1C4008","#113001")

#heterogeneity matrix — movement rec per unique user  ratio 
class_colors <- c("#feebe2","#fbb4b9","#f768a1","#c51b8a","#7a0177") #sequential&scheme=RdPu&n=5
class_colors <- c("#CDCDCD","#FDD7C7","#F7BFBE","#EEA8B4","#E392A9","#D67D9D","#C86991","#B75683","#A64476","#933367","#802358","#6B1449","#57073A","#41002A") # http://tristen.ca/hcl-picker/#/clh/13/106/113001/F2FBB9





#draw heatmap
image(binsx, binsy, freq2D, zlim=c(1, max(freq2D)), col= class_colors, breaks = raw_breaks)
title(main = title, font.main = 4)
abline(h= y, v=x, col = rgb(1,1,1, 0.4 , maxColorValue = 1))


#draw heatmap for difference matrix
image(binsx, binsy, freq2D_diff,  col= class_colors, breaks = raw_breaks)
title(main = title, font.main = 4)
abline(h= y, v=x, col = rgb(1,1,1, 0.4 , maxColorValue = 1))
abline(h= y, v=x, col = rgb(1,1,1, 0.4 , maxColorValue = 1))

#draw heatmap for unique user matrix
title = "DURATION-DISTANCE, unique user counts"
image(binsx, binsy, unique_user_matrix,  col= class_colors, breaks = raw_breaks)
title(main = title, font.main = 4)
abline(h= y, v=x, col = rgb(1,1,1, 0.4 , maxColorValue = 1))


#draw heatmap for movement rec per unique user  ratio matrix
image(binsx, binsy, ratio_matrix,  col= class_colors, breaks = raw_breaks)
title(main = title, font.main = 4)
abline(h= y, v=x, col = rgb(1,1,1, 0.4 , maxColorValue = 1))

#draw lines of equal speed

#coordinates

x1 <- c(0.1, 0.34657359,0.693147181,1.386294361,2.079441542,2.772588722,3.465735903,4.158883083,4.852030264,5.545177444,6.238324625,6.931471806,7.624618986,8.317766167,9.010913347)
x2 <- c(0.34657359,0.693147181,1.386294361,2.079441542,2.772588722,3.465735903,4.158883083,4.852030264,5.545177444,6.238324625,6.931471806,7.624618986,8.317766167,9.010913347)
x3 <- c(2.079441542,2.772588722,3.465735903,4.158883083,4.852030264,5.545177444,6.238324625,6.931471806,7.624618986,8.317766167,9.010913347)
x4 <- c(8.317766167,9.010913347)


y1 <-c(4.787492,6.208703,7.090077,8.188689,9.035987,9.798127,10.524064,11.233212,11.934264,12.631340,13.326446,14.020572,14.714207,15.407599,16.100868)
y2 <-c(2.667228,4.088440,4.969813,6.068426,6.915723,7.677864,8.403801,9.112948,9.814000,10.511077,11.206183,11.900308,12.593944,13.287335,13.980605)
y3 <-c(1.637609,3.058820,3.940194,5.038806,5.886104,6.648244,7.374181,8.083329,8.784381,9.481457,10.176563,10.870689,11.564324,12.257716,12.950985)
y4 <-c(0.997397,1.878771,2.977383,3.824681,4.586821,5.312758,6.021906,6.722958,7.420034,8.115140,8.809266,9.502901,10.196293,10.889562)
y5 <-c(0.091350,0.853490,1.579427,2.288574,2.989627,3.686703,4.381809,5.075934,5.769570,6.462962,7.156231)
y6 <-c(0.388115,1.081385)


lines(x1, y1, type="b", col = rgb(1,1,1, 0.4 , maxColorValue = 1))
lines(x1, y2, type="b", col = rgb(1,1,1, 0.4 , maxColorValue = 1))
lines(x1, y3, type="b", col = rgb(1,1,1, 0.4 , maxColorValue = 1))

lines(x2, y4, type="b", col = rgb(1,1,1, 0.4 , maxColorValue = 1))
lines(x3, y5, type="b", col = rgb(1,1,1, 0.4 , maxColorValue = 1))
lines(x4, y6, type="b", col = rgb(1,1,1, 0.4 , maxColorValue = 1))