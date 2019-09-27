#userId + "\t" + name + "\t" + time2 + "\t" + dur + "\t" + distStr + "\t" + speedStr + "\t" + lat1 + "\t" + lon1 + "\t" + lat2 + "\t" + lon2 + "\t" + userMention + "\t" + media + "\t" + hashtags + "\t" + cleanText + "\n";

plane_like_data <- scan("D:/Andrei/movement_analysis/blobs/distributedReader.2.1.twitterCrawler01.2017.12.merged.planeLike.out", sep="\t", quote="",  what=list(NULL, character(),  NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, character(), character()))
car_like_data <- scan("D:/Andrei/movement_analysis/blobs/distributedReader.2.1.twitterCrawler01.2017.12.merged.carLike.out", sep="\t", quote="",  what=list(NULL, character(),  NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, character(), character()))
top_blob_data <- scan("D:/Andrei/movement_analysis/blobs/distributedReader.2.1.twitterCrawler01.2017.12.merged.topBlob.out", sep="\t", quote="",  what=list(NULL, character(),  NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, character(), character()))
central_blob_data <- scan("D:/Andrei/movement_analysis/blobs/distributedReader.2.1.twitterCrawler01.2017.12.merged.centralBlob.out", sep="\t", quote="",  what=list(NULL, character(),  NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, character(), character()))
edge_blob_data <- scan("D:/Andrei/movement_analysis/blobs/distributedReader.2.1.twitterCrawler01.2017.12.merged.edgeBlob.out", sep="\t", quote="",  what=list(NULL, character(),  NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, character(), character()))
bottomRight_blob_data <- scan("D:/Andrei/movement_analysis/blobs/distributedReader.2.1.twitterCrawler01.2017.12.merged.bottomRight.out", sep="\t", quote="",  what=list(NULL, character(),  NULL, NULL, NULL, NULL,NULL, NULL, NULL, NULL, NULL, NULL, character(), character()))




plane_like_data_list <- list (name = plane_like_data[[2]], hashtag = plane_like_data[[13]], text = plane_like_data[[14]])
car_like_data_list <- list (name = car_like_data[[2]], hashtag = car_like_data[[13]], text = car_like_data[[14]])
top_blob_data_list <- list (name = top_blob_data[[2]], hashtag = top_blob_data[[13]], text = top_blob_data[[14]])
central_blob_data_list <- list (name = central_blob_data[[2]], hashtag = central_blob_data[[13]], text = central_blob_data[[14]])
edge_blob_data_list <- list (name = edge_blob_data[[2]], hashtag = edge_blob_data[[13]], text = edge_blob_data[[14]])
bottomRight_blob_data_list <- list (name = bottomRight_blob_data[[2]], hashtag = bottomRight_blob_data[[13]], text = bottomRight_blob_data[[14]])


plane_like_DataFrame <- as.data.frame(plane_like_data_list)
car_like_DataFrame <- as.data.frame(car_like_data_list)
top_blob_DataFrame <- as.data.frame(top_blob_data_list)
central_blob_DataFrame <- as.data.frame(central_blob_data_list)
edge_blob_DataFrame <- as.data.frame(edge_blob_data_list)
bottomRight_blob_DataFrame <- as.data.frame(bottomRight_blob_data_list)



plane_like_hastags<-strsplit(as.character(plane_like_DataFrame$hashtag)," ")
plane_like_hastags.freq<-table(unlist(plane_like_hastags));
plane_like_hastags_count <- cbind.data.frame(names(plane_like_hastags.freq),as.integer(plane_like_hastags.freq))
top100_hashtags_plane_like<-head(plane_like_hastags_count[order(-plane_like_hastags_count$`as.integer(plane_like_hastags.freq)`),],100)
                             
car_like_hastags<-strsplit(as.character(car_like_DataFrame$hashtag)," ")
car_like_hastags.freq<-table(unlist(car_like_hastags));
car_like_hastags_count <- cbind.data.frame(names(car_like_hastags.freq),as.integer(car_like_hastags.freq))
top100_hashtags_car_like<-head(car_like_hastags_count[order(-car_like_hastags_count$`as.integer(car_like_hastags.freq)`),],100)
                             
top_blob_hastags<-strsplit(as.character(top_blob_DataFrame$hashtag)," ")
top_blob_hastags.freq<-table(unlist(top_blob_hastags));
top_blob_hastags_count <- cbind.data.frame(names(top_blob_hastags.freq),as.integer(top_blob_hastags.freq))
top100_hashtags_top_blob<-head(top_blob_hastags_count[order(-top_blob_hastags_count$`as.integer(top_blob_hastags.freq)`),],100)
                             
central_blob_hastags<-strsplit(as.character(central_blob_DataFrame$hashtag)," ")
central_blob_hastags.freq<-table(unlist(central_blob_hastags));
central_blob_hastags_count <- cbind.data.frame(names(central_blob_hastags.freq),as.integer(central_blob_hastags.freq))
top100_hashtags_central_blob<-head(central_blob_hastags_count[order(-central_blob_hastags_count$`as.integer(central_blob_hastags.freq)`),],100)
                             
edge_blob_hastags<-strsplit(as.character(edge_blob_DataFrame$hashtag)," ")
edge_blob_hastags.freq<-table(unlist(edge_blob_hastags));
edge_blob_hastags_count <- cbind.data.frame(names(edge_blob_hastags.freq),as.integer(edge_blob_hastags.freq))
top100_hashtags_edge_blob<-head(edge_blob_hastags_count[order(-edge_blob_hastags_count$`as.integer(edge_blob_hastags.freq)`),],100)

bottomRight_blob_hastags<-strsplit(as.character(bottomRight_blob_DataFrame$hashtag)," ")
bottomRight_blob_hastags.freq<-table(unlist(bottomRight_blob_hastags));
bottomRight_blob_hastags_count <- cbind.data.frame(names(bottomRight_blob_hastags.freq),as.integer(bottomRight_blob_hastags.freq))
top100_hashtags_bottomRight_blob<-head(bottomRight_blob_hastags_count[order(-bottomRight_blob_hastags_count$`as.integer(bottomRight_blob_hastags.freq)`),],100)





random_plane_like_1000 <- plane_like_DataFrame[sample(nrow(plane_like_DataFrame), 1000), ]
random_car_like_1000 <- car_like_DataFrame[sample(nrow(car_like_DataFrame), 1000), ]
random_top_blob_1000 <- top_blob_DataFrame[sample(nrow(top_blob_DataFrame), 1000), ]
random_central_blob_1000 <- central_blob_DataFrame[sample(nrow(central_blob_DataFrame), 1000), ]
random_edge_blob_1000 <- edge_blob_DataFrame[sample(nrow(edge_blob_DataFrame), 1000), ]
random_bottomRight_blob_1000 <- bottomRight_blob_DataFrame[sample(nrow(bottomRight_blob_DataFrame), 1000), ]


write.csv(top100_hashtags_plane_like, file = "D:/Andrei/movement_analysis/blobs/top100_hashtags_plane_like.txt")
write.csv(top100_hashtags_car_like, file = "D:/Andrei/movement_analysis/blobs/top100_hashtags_car_like.txt")
write.csv(top100_hashtags_top_blob, file = "D:/Andrei/movement_analysis/blobs/top100_hashtags_top_blob.txt")
write.csv(top100_hashtags_central_blob, file = "D:/Andrei/movement_analysis/blobs/top100_hashtags_central_blob.txt")
write.csv(top100_hashtags_edge_blob, file = "D:/Andrei/movement_analysis/blobs/top100_hashtags_edge_blob.txt")
write.csv(top100_hashtags_bottomRight_blob, file = "D:/Andrei/movement_analysis/blobs/top100_hashtags_bottomRight_blob.txt")



write.csv(random_plane_like_1000, file = "D:/Andrei/movement_analysis/blobs/random_plane_like_1000.txt")
write.csv(random_car_like_1000, file = "D:/Andrei/movement_analysis/blobs/random_car_like_1000.txt")
write.csv(random_top_blob_1000, file = "D:/Andrei/movement_analysis/blobs/random_top_blob_1000.txt")
write.csv(random_central_blob_1000, file = "D:/Andrei/movement_analysis/blobs/random_central_blob_1000.txt")
write.csv(random_edge_blob_1000, file = "D:/Andrei/movement_analysis/blobs/random_edge_blob_1000.txt")
write.csv(random_bottomRight_blob_1000, file = "D:/Andrei/movement_analysis/blobs/random_bottomRight_blob_1000.txt")


write.csv(paste(plane_like_DataFrame$text,sep="", collapse=" "),file = "D:/Andrei/movement_analysis/blobs/plane_like_DataFrame_text.txt")
write.csv(paste(car_like_DataFrame$text,sep="", collapse=" "),file = "D:/Andrei/movement_analysis/blobs/car_like_DataFrame_text.txt")
write.csv(paste(top_blob_DataFrame$text,sep="", collapse=" "),file = "D:/Andrei/movement_analysis/blobs/top_blob_DataFrame_text.txt")
write.csv(paste(edge_blob_DataFrame$text,sep="", collapse=" "),file = "D:/Andrei/movement_analysis/blobs/edge_blob_DataFrame_text.txt")
write.csv(paste(central_blob_DataFrame$text,sep="", collapse=" "),file = "D:/Andrei/movement_analysis/blobs/central_blob_DataFrame_text.txt")
write.csv(paste(bottomRight_blob_DataFrame$text,sep="", collapse=" "),file = "D:/Andrei/movement_analysis/blobs/bottomRight_blob_DataFrame_text.txt")
