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



random_plane_like_1000 <- plane_like_DataFrame[sample(nrow(plane_like_DataFrame), 1000), ]
random_car_like_1000 <- car_like_DataFrame[sample(nrow(car_like_DataFrame), 1000), ]
random_top_blob_1000 <- top_blob_DataFrame[sample(nrow(top_blob_DataFrame), 1000), ]
random_central_blob_1000 <- central_blob_DataFrame[sample(nrow(central_blob_DataFrame), 1000), ]
random_edge_blob_1000 <- edge_blob_DataFrame[sample(nrow(edge_blob_DataFrame), 1000), ]
random_bottomRight_blob_1000 <- bottomRight_blob_DataFrame[sample(nrow(bottomRight_blob_DataFrame), 1000), ]


write.csv(random_plane_like_1000, file = "D:/Andrei/movement_analysis/blobs/random_plane_like_1000.txt")
write.csv(random_car_like_1000, file = "D:/Andrei/movement_analysis/blobs/random_car_like_1000.txt")
write.csv(random_top_blob_1000, file = "D:/Andrei/movement_analysis/blobs/random_top_blob_1000.txt")
write.csv(random_central_blob_1000, file = "D:/Andrei/movement_analysis/blobs/random_central_blob_1000.txt")
write.csv(random_edge_blob_1000, file = "D:/Andrei/movement_analysis/blobs/random_edge_blob_1000.txt")
write.csv(random_bottomRight_blob_1000, file = "D:/Andrei/movement_analysis/blobs/random_bottomRight_blob_1000.txt")

