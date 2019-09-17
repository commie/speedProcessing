users <- scan('C:/Users/a_k257/Documents/GitHub/speedProcessing/r/heterogeneity_heatmap/unique_users.txt')
user_matrix <- matrix(users,nrow = 100,ncol = 100, byrow = TRUE)

raw_hist <- hist(users[users > 0], 100)
#use log scale for histogram counts
log_hist <-raw_hist
raw_counts <- log_hist[['counts']]
log_counts <- log(raw_counts+1)
log_hist[['counts']] = log_counts
plot(log_hist)




raw_breaks <- c(0.9,100,490,2400,11800,55000) ## geometric series starting 100 with base of 4.9
class_colors <- c("#f0f9e8","#bae4bc","#7bccc4","#43a2ca","#0868ac")

raw_breaks <- c(0,0.9,100,170,290,490,835,1420,2415,4100,7000,11900,20200,34300,55000) ## geometric series starting 100 with base of 1.7
class_colors <- c("#CDCDCD","#F2FBB9","#D9EAA2","#C0D98C","#A9C878","#93B665","#7EA554","#6A9444","#588235","#477128","#37601C","#295012","#1C4008","#113001")

image(z=user_matrix, zlim=c(1, max(user_matrix)), col= class_colors, breaks = raw_breaks)




users <- scan('C:/Users/a_k257/Documents/GitHub/speedProcessing/r/heterogeneity_heatmap/rec_per_user_ratio.txt')
user_matrix <- matrix(users,nrow = 100,ncol = 100, byrow = TRUE)

raw_hist <- hist(users[users > 0], 100)
#use log scale for histogram counts
log_hist <-raw_hist
raw_counts <- log_hist[['counts']]
log_counts <- log(raw_counts+1)
log_hist[['counts']] = log_counts
plot(log_hist)

max(users)


raw_breaks <- c(0.9,2,8,35,150,600)
class_colors <- c("#feebe2","#fbb4b9","#f768a1","#c51b8a","#7a0177") #sequential&scheme=RdPu&n=5


raw_breaks <- c(0,0.9,2,3.2,5.2,8.,13,22,35,56,90,145,235,380,600) ## geometric series starting 2 with base of 1.61
class_colors <- c("#CDCDCD","#FDD7C7","#F7BFBE","#EEA8B4","#E392A9","#D67D9D","#C86991","#B75683","#A64476","#933367","#802358","#6B1449","#57073A","#41002A") 

image(z=user_matrix, zlim=c(1, max(user_matrix)), col= class_colors, breaks = raw_breaks)
