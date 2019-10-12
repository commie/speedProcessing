users <- scan('C:/Users/a_k257/Documents/GitHub/speedProcessing/r/location_heterogeniety/unique_locations.txt')
user_matrix <- matrix(users,nrow = 100,ncol = 100, byrow = TRUE)

raw_hist <- hist(users[users > 0], 100)
#use log scale for histogram counts
log_hist <-raw_hist
raw_counts <- log_hist[['counts']]
log_counts <- log(raw_counts+1)
log_hist[['counts']] = log_counts
plot(log_hist)




raw_breaks <- c(0,0.9,300,1025,3500,12000,40800) ## geometric series starting 300 with base of 3.415
class_colors <- c("#CDCDCD","#f0f9e8","#bae4bc","#7bccc4","#43a2ca","#0868ac")

raw_breaks <- c(0,0.9,100,165,270,450,750,1200,2000,3300,5500,9100,15000,25000,40800) ## geometric series starting 100 with base of 1.65
class_colors <- c("#CDCDCD","#F2FBB9","#D9EAA2","#C0D98C","#A9C878","#93B665","#7EA554","#6A9444","#588235","#477128","#37601C","#295012","#1C4008","#113001")

image(z=user_matrix, zlim=c(1, max(user_matrix)), col= class_colors, breaks = raw_breaks)




users <- scan('C:/Users/a_k257/Documents/GitHub/speedProcessing/r/location_heterogeniety/rec_per_location_ratio.txt')
user_matrix <- matrix(users,nrow = 100,ncol = 100, byrow = TRUE)

raw_hist <- hist(users[users > 0], 100)
#use log scale for histogram counts
log_hist <-raw_hist
raw_counts <- log_hist[['counts']]
log_counts <- log(raw_counts+1)
log_hist[['counts']] = log_counts
plot(log_hist)

max(users)


raw_breaks <- c(0,0.9,2,6,20,60,190) ## geometric series starting 2 with base of 3.11
class_colors <- c("#CDCDCD","#feebe2","#fbb4b9","#f768a1","#c51b8a","#7a0177") #sequential&scheme=RdPu&n=5


raw_breaks <- c(0,0.9,2,2.9,4.3,6.2,9,13,19,28,40,60,90,130,190)  ## geometric series starting 2 with base of 1.46
class_colors <- c("#CDCDCD","#FDD7C7","#F7BFBE","#EEA8B4","#E392A9","#D67D9D","#C86991","#B75683","#A64476","#933367","#802358","#6B1449","#57073A","#41002A") 

image(z=user_matrix, zlim=c(1, max(user_matrix)), col= class_colors, breaks = raw_breaks)
