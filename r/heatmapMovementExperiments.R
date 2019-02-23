sampleData <- scan("F:/distributedReader.2.1.twitterCrawler01.2017.12.merged.movement.out", sep="\t", quote="", nmax=10000,  what=list(NULL, NULL, NULL, NULL, NULL, numeric(),NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL))


maxSpeed <- 0

numRec <- length(sampleData[[6]])

for (i in 1:numRec) {
	if (!is.nan(sampleData[[6]][i]) && !is.infinite(sampleData[[6]][i]) ){
		if (sampleData[[6]][i] > maxSpeed) {

			maxSpeed <- sampleData[[6]][i];

		}
	}

	# if (i %% 1000 == 0) {
	# 	print(i)
	# }
	
}



nbins <- 100

bins <- seq(0, 1, length=nbins)

freq2D <- diag(nbins)*0

numRec <- length(sampleData[[8]])

for (i in 1:numRec) {

	leftValid	<- as.logical(sampleData[[23]][i]);
	rightValid	<- as.logical(sampleData[[8]][i]);

	if (leftValid && rightValid) {

		# right eye
		xBin <- findInterval(sampleData[[12]][i], bins);
		yBin <- findInterval(1 - sampleData[[13]][i], bins);

		freq2D[xBin, yBin] <- freq2D[xBin, yBin] + 1;
	}
}

library(RColorBrewer)

par(bg="grey90") # needed every time
image(bins, bins, freq2D, zlim=c(1, max(freq2D)), col=brewer.pal(9, "Blues")) # exclude cells with 0 count or just suppress for plotting?