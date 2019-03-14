fullData <- scan("D:/Andrei/distributedReader.2.1.twitterCrawler01.2017.12.merged.movement.out", sep="\t", quote="",  what=list(NULL, NULL,  NULL, numeric(), numeric(), numeric(),NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))  #duration, distance, speed

selectedDataList <- list (duration = fullData[[4]], distance = fullData[[5]], speed = fullData[[6]])

selectedDataFrame <- as.data.frame(selectedDataList)

#filteredData <- selectedDataList[which(selectedDataList$duration > 0 & is.finite(selectedDataList$speed)) & is.finite(selectedDataList$distance)),] #no neg durations, speed, no Nan no Inf
filteredData <- selectedDataList[which(selectedDataList$duration > 0),]  #no neg durations, speed, no Nan no Inf

# calculate log for each column
filteredData$distance_log = log(filteredData$distance+1)
filteredData$speed_log = log(filteredData$speed+1) 
filteredData$duration_log = log(filteredData$duration) 

#calculate max values
distance_log_max = max(filteredData$distance_log)
speed_log_max = max(filteredData$speed_log)
duration_log_max = max(filteredData$duration_log)

# number of cells horizontalli and vertically
nBins<-100

# bin records into heatmap cells for speed and duration ####################################################################### 
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

# bin records into heatmap cells for speed and distance ####################################################################### 
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

# bin records into heatmap cells for duration and distance ####################################################################### 
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


# histogram 
raw_hist <- hist(freq2D[freq2D > 0], 100)


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
# class_breaks <- c(0,0.01738625,0.88391575,1.75044525,2.61697475,3.48350425,4.35003375,5.21656325,6.08309275,6.94962225,7.81615175,8.68268125,9.54921075,10.41574025, 11.28226975) # speed-duration sd = 1.733059  mean = 5.649828 max = 11.06507
class_breaks <- c(0,1.040024,1.834502,2.62898,3.423458,4.217936,5.012414,5.806892,6.60137,7.395848,8.190326,8.984804,9.779282) # duration-distance sd = 1.588956  mean = 5.409653 max = 9.134647
#class_breaks <- c(0,0.3271875,1.2229525,2.1187175,3.0144825,3.9102475,4.8060125,5.7017775,6.5975425,7.4933075,8.3890725,9.2848375,10.1806025,11.0763675) # speed-distance sd = 1.79153  mean = 5.253895 max = 12.25384
raw_breaks <- exp(class_breaks)

# set the first break to 0; make sure 1 is included into second bin
raw_breaks[1]=0
raw_breaks[2]=0.9

#go to color picker for data and pick colors http://tristen.ca/hcl-picker/
# first color is grey for background
# class_colors <- c("#CDCDCD","#F9E8FB","#E4D5F6","#CFC3F0","#BAB2E7","#A5A1DD","#9191D1","#7D80C4","#6A71B6","#5862A6","#475395","#364582","#27376F","#192A5B")
class_colors <- c("#CDCDCD","#F9E8FB","#E0D2F5","#C6BCEC","#ADA8E1","#9594D4","#7D80C4","#676EB3","#515C9F","#3D4A8A","#2A3A73","#192A5B")
# class_colors <- c("#CDCDCD","#F9E8FB","#E2D4F6","#CBC0EE","#B4ADE5","#9E9BD9","#8889CC","#7378BD","#5F67AC","#4B5799","#394786","#283871","#192A5B")

#draw heatmap
image(binsx, binsy, freq2D, zlim=c(1, max(freq2D)), col= class_colors, breaks = raw_breaks)