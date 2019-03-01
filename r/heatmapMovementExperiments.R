sampleData <- scan("D:/Andrei/distributedReader.2.1.twitterCrawler01.2017.12.merged.movement.out", sep="\t", quote="", nmax=10000,  what=list(NULL, NULL,  NULL, numeric(), NULL, numeric(),NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))
fullData <- scan("D:/Andrei/distributedReader.2.1.twitterCrawler01.2017.12.merged.movement.out", sep="\t", quote="",  what=list(NULL, NULL,  NULL, numeric(), NULL, numeric(),NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))

fdlist <- list (duration = fullData[[4]], speed = fullData[[6]])
datalist <- list (duration = sampleData[[4]], speed = sampleData[[6]])

tdData <- as.data.frame(datalist)
ftdData <- as.data.frame(fdlist)

filteredData <- ftdData[which(ftdData$duration > 0 & is.finite(ftdData$speed)),] #no neg durations, speed, no Nan no Inf

filteredData$sp_log = log10(filteredData$speed+1) # add log column for speed +1
filteredData$dur_log = log10(filteredData$duration) # add log column for duration/ it is already not 0 after filtering

speed_log_range <- range(filteredData$sp_log)
dur_log_range <- range(filteredData$dur_log)

nBins<-100

DurBinSize <- dur_log_range[2]/nBins
SpeedBinSize <- speed_log_range[2]/nBins

#maxSpeed <- 0

#numRec <- length(sampleData[[6]])

#for (i in 1:numRec) {
#	if (!is.nan(sampleData[[6]][i]) && !is.infinite(sampleData[[6]][i]) ){
#		if (sampleData[[6]][i] > maxSpeed) {
#
#			maxSpeed <- sampleData[[6]][i];
#
#		}
#	}

	# if (i %% 1000 == 0) {
	# 	print(i)
	# }
	
#}




bins <- seq(0, 1, length=nBins)

freq2D <- diag(nBins)*0

numRec <- length(filteredData)

for (i in 1:numRec) {

	speed_log	<- filteredData$sp_log[i];
	dur_log	<- filteredData$dur_log[i];

	if (speed_log && dur_log) {

		# 
		xBin <- findInterval(speed_log, bins);
		yBin <- findInterval(1 - dur_log, bins);

		freq2D[xBin, yBin] <- freq2D[xBin, yBin] + 1;
	}
}

library(RColorBrewer)

par(bg="grey90") # needed every time
image(bins, bins, freq2D, zlim=c(1, max(freq2D)), col=brewer.pal(9, "Blues")) # exclude cells with 0 count or just suppress for plotting?