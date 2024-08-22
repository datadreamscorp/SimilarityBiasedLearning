#Plots for The Evolution of Similarity-Biased Social Learning
#by Paul E. Smaldino and Alejandro Perez Velilla. Last updated August 2024

#import libraries
library(ggplot2)
library (cowplot)
library(dplyr)
library(viridis)
library(this.path)
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
setwd(this.path::here())

#---------------------------------------------
# 1. Social learning evolves when individual learning is more uncertain
#---------------------------------------------

#clear the workspace
rm(list = ls()) 
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
mydata <- read.csv("./analysis_3_1.csv", skip = 0, header = TRUE, sep = ",")

#get means across runs
md.mean <- mydata %>% group_by(sigma_l, mu_r) %>% summarise_each(funs(mean))
df <- mydata[which(mydata$mu_r == 0.05), ] 
df.mean <- df %>% group_by(sigma_l) %>% summarise_each(funs(mean))

#evolution of social learning
ggplot(df, aes(x = sigma_l, y = mean_social_final)) + 
  geom_point(size = 1, alpha = 0.05) +
  geom_line(data=df.mean, aes(x = sigma_l, y = mean_social_final), linewidth=1.2) +
  scale_x_continuous(limits=c(0, 0.5)) +
  #scale_y_continuous(limits=c(0, 1)) +
  labs(x =expression(paste("individual learning uncertainty, ",sigma[l])), y="social learning reliance") + 
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.position = c(0.85, .8))  + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4

#evolution of social learning - payoff
ggplot(mydata, aes(x = sigma_l, y = mean_payoff_final, color=factor(mu_r))) + 
  geom_point(size = 1, alpha = 0.05) +
  geom_line(data=md.mean, aes(x = sigma_l, y = mean_payoff_final, color=factor(mu_r)), linewidth=1.2) +
  scale_x_continuous(limits=c(0, 0.5)) +
  scale_y_continuous(limits=c(0, 1)) +
  labs(x =expression(paste("individual learning uncertainty, ",sigma[l])), y="average payoff", color=expression(paste(mu[R]))) + 
  scale_colour_manual(values=cbPalette) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.position = c(0.14, .18))  + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4



#---------------------------------------------
# 2. Social learning relies on correlated environments
#---------------------------------------------

rm(list = ls()) 
#cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

mydata <- read.csv("./analysis_3_2.csv", skip = 0, header = TRUE, sep = ",")
#use default values
df <- mydata[which(mydata$N == 200  & mydata$sigma_l == 0.3 & mydata$n ==1), ] 
md.mean <- df %>% group_by(theta, f) %>% summarise_each(funs(mean))

#evolution of social learning - group 1 is the smaller group (square)
ggplot(df, aes(x = theta,  color=factor(f))) + 
  geom_point(aes(y = mean_social_g0_final), size = 1, alpha = 0.05, shape=16) +
  geom_point(aes(y = mean_social_g1_final), size = 1, alpha = 0.05, shape=0) +
  geom_line(data=md.mean, aes(y = mean_social_g0_final, ), linewidth=1, linetype="solid") +
  geom_line(data=md.mean, aes(y = mean_social_g1_final, ), linewidth=1, linetype="dashed") +
  scale_x_continuous(limits=c(0, 180), breaks=c(0, 45, 90, 135, 180)) +
  #scale_y_continuous(limits=c(0, 1)) +
  labs(x =expression(paste("distance between adaptive traits, ",theta)), y="social learning reliance", color="f") + 
  scale_colour_manual(values=cbPalette) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  #theme(legend.position = c(0.85, .8))  + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4.5 (for triptych)


#---------------------------------------------
# 3. Parochial social learning helps
#---------------------------------------------

#First batch: one-model runs
#These are for the 50-50 groups, looking at the evolution of parochialism
#Check different n values

rm(list = ls()) 
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
mydata <- read.csv("./analysis_3_3.csv", skip = 0, header = TRUE, sep = ",")
#N = {50, 200}, n = {1, 5, 15}, sigma_l = [0: 0.01: 0.5], f = {0.5, 0.7, 0.9}
#Baseline for most figures: N=200, n=5, sigmal=0.3, f=0.5

df <- mydata[which(mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5), ] 
df.mean <- df %>% group_by(theta, ID_corr) %>% summarise_each(funs(mean))
#evolution of parochial social learning
ggplot(df, aes(x = theta, y = mean_parochial_final, color=factor(ID_corr))) + 
  geom_point(size = 1, alpha = 0.2) + #, shape=16) +
  geom_line(data=df.mean, aes(x = theta, y = mean_parochial_final, color=factor(ID_corr)), linewidth=1, linetype="solid") +
  scale_x_continuous(limits=c(0, 180), breaks=c(0, 45, 90, 135, 180)) +
  labs(x =expression(paste("distance between adaptive traits, ",theta)), y="parochial social learning", color="R") + 
  scale_color_viridis(discrete = TRUE) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4.5

df <- mydata[which(mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5), ] 
df.mean <- df %>% group_by(theta, ID_corr) %>% summarise_each(funs(mean))

#evolution of  social learning reliance
ggplot(df, aes(x = theta, y = mean_social_final, color=factor(ID_corr))) +  
  geom_point(size = 1, alpha = 0.2) + #, shape=16) +
  geom_line(data=df.mean, linewidth=1, linetype="solid") +
  scale_x_continuous(limits=c(0, 180), breaks=c(0, 45, 90, 135, 180)) +
  #scale_y_continuous(limits=c(0, 1)) +
  labs(x =expression(paste("distance between adaptive traits, ",theta)), y="social learning reliance", color="R") + 
  #labs(title="n=5, sigma_l = 0.5") +
  scale_color_viridis(discrete = TRUE) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  #theme(legend.position = c(0.15, .3))  + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4.5

#plot social learning reliance vs. parochialism for theta = 180
df <- mydata[which(mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5 & mydata$theta == 180), ] 
df.mean <- df %>% group_by(ID_corr) %>% summarise_each(funs(mean))
ggplot(df, aes(x = mean_social_final, y = mean_parochial_final, color=factor(ID_corr))) + 
  geom_point(size = 2, alpha = 0.6) + #, shape=16) +
  labs(x =expression(paste("social learning reliance")), y="parochial social learning", color="R") + 
  scale_color_viridis(discrete = TRUE) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.position = c(0.85, .26))  + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4


#Track Group sizes
df <- mydata[which(mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$ID_corr == 1), ] 
#N = {50, 200}, n = {1, 5, 15}, sigma_l = [0: 0.01: 0.5], f = {0.5, 0.7, 0.9}, ID_corr = [0, 1]
df.mean <- df %>% group_by(theta, f) %>% summarise_each(funs(mean))

#cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
cbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

#-------DIFFERENT GROUP SIZES

#evolution of social learning - group 1 is the smaller group (square, dashed line) R = 1
ggplot(df, aes(x = theta,  color=factor(f))) + 
  geom_point(aes(y = mean_social_g0_final), size = 1, alpha = 0.2, shape=16) +
  geom_point(aes(y = mean_social_g1_final), size = 1, alpha = 0.2, shape=0) +
  geom_line(data=df.mean, aes(y = mean_social_g0_final, ), linewidth=1, linetype="solid") +
  geom_line(data=df.mean, aes(y = mean_social_g1_final, ), linewidth=1, linetype="dashed") +
  scale_colour_manual(values=cbPalette) +
  labs(x =expression(paste("distance between adaptive traits, ",theta)), y="social learning reliance", color="f") + #, title = "Dashed lines are smaller groups") + 
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4.5

#evolution of parochial social learning - group 1 is the smaller group (square, dashed line) R = 1
ggplot(df, aes(x = theta,  color=factor(f))) + 
  geom_point(aes(y = mean_parochial_g0_final), size = 1, alpha = 0.2, shape=16) +
  geom_point(aes(y = mean_parochial_g1_final), size = 1, alpha = 0.2, shape=0) +
  geom_line(data=df.mean, aes(y = mean_parochial_g0_final, ), linewidth=1, linetype="solid") +
  geom_line(data=df.mean, aes(y = mean_parochial_g1_final, ), linewidth=1, linetype="dashed") +
  scale_colour_manual(values=cbPalette) +
  labs(x =expression(paste("distance between adaptive traits, ",theta)), y="parochial social learning", color="f") + #, title = "Dashed lines are smaller groups") + 
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4.5


#Is parochial social learning correlated with social learing reliance? 
#Plot for theta = 180, parochial social learning vs. social learning reliance
# for all values of R
df <- mydata[which(mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5 & mydata$theta == 180), ] 
df.mean <- df %>% group_by(ID_corr) %>% summarise_each(funs(mean))

ggplot(df, aes(x = mean_social_final, y = mean_parochial_final, color=factor(ID_corr))) + 
  geom_point(size = 2, alpha = 0.6) + #, shape=16) +
  labs(x =expression(paste("social learning reliance")), y="parochial social learning", color="R") + 
  scale_colour_manual(values=cbPalette) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.position = c(0.88, .24))  + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4


#---------------------------------------------
# 4A. Learning Biases -- Conformity
#---------------------------------------------

rm(list = ls()) 
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
mydata <- read.csv("./analysis_3_4.csv", skip = 0, header = TRUE, sep = ",")
#N = {50, 200}, n = {1, 5, 15}, sigma_l = [0: 0.01: 0.5], f = {0.5, 0.7, 0.9}, strategies = {UL&CB, UL&PB}

#CONFORMITY
df <- mydata[which(mydata$strategies == "UL&CB" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5), ] 
df.mean <- df %>% group_by(theta, ID_corr) %>% summarise_each(funs(mean))
#will return a warning because the strategy type is non-numeric. It's fine. 

#which social learning strategies evolve
ggplot(df, aes(x = theta, y = prop_conformist_final, color=factor(ID_corr))) + 
  geom_point(size = 1, alpha = 0.2) + #, shape=16) +
  geom_line(data=df.mean, aes(x = theta, y = prop_conformist_final, color=factor(ID_corr)), linewidth=1, linetype="solid") +
  scale_x_continuous(limits=c(0, 180), breaks=c(0, 45, 90, 135, 180)) +
  labs(x =expression(paste("distance between adaptive traits, ",theta)), y="proportion conformist social learning", color="R") + 
  scale_color_viridis(discrete = TRUE,option="plasma", direction = -1) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4.5

df <- mydata[which(mydata$strategies == "UL&CB" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5),]
df.mean <- df %>% group_by(theta, ID_corr) %>% summarise_each(funs(mean))

#evolution of parochial social learning
ggplot(df, aes(x = theta, y = mean_parochial_final, color=factor(ID_corr))) + 
  geom_point(size = 1, alpha = 0.2) + #, shape=16) +
  geom_line(data=df.mean, aes(x = theta, y = mean_parochial_final, color=factor(ID_corr)), linewidth=1, linetype="solid") +
  scale_x_continuous(limits=c(0, 180), breaks=c(0, 45, 90, 135, 180)) +
  labs(x =expression(paste("distance between adaptive traits, ",theta)), y="parochial social learning", color="R") + 
  scale_color_viridis(discrete = TRUE) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4.5

#look at all the runs for social learning reliance
df <- mydata[which(mydata$strategies == "UL&CB" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5), ] 
df.mean <- df %>% group_by(theta, ID_corr) %>% summarise_each(funs(mean))
#evolution of  social learning reliance
ggplot(df, aes(x = theta, y = mean_social_final, color=factor(ID_corr))) +  
  geom_point(size = 1, alpha = 0.2) + #, shape=16) +
  geom_line(data=df.mean, linewidth=1, linetype="solid") +
  scale_x_continuous(limits=c(0, 180), breaks=c(0, 45, 90, 135, 180)) +
  scale_y_continuous(limits=c(0, 1)) +
  labs(x =expression(paste("distance between adaptive traits, ",theta)), y="social learning reliance", color="R") + 
  scale_color_viridis(discrete = TRUE) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4

#Is parochial social learning correlated with social learing reliance? 
#Plot for R = 1, parochial social learning vs. social learning reliance
# for theta = {0, 45, 90, 135, 180}
df <- mydata[which(mydata$strategies == "UL&CB" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5 & mydata$ID_corr == 1 & (mydata$theta == 0 | mydata$theta <= 40 | mydata$theta == 90 | mydata$theta == 130 | mydata$theta == 180)), ] 
df.mean <- df %>% group_by(theta) %>% summarise_each(funs(mean))

ggplot(df, aes(x = mean_social_final, y = mean_parochial_final, color=factor(theta))) + 
  geom_point(size = 2, alpha = 0.6) + #, shape=16) +
  scale_x_continuous(limits=c(0.8, 1)) +
  labs(x =expression(paste("social learning reliance")), y="parochial social learning", color="theta") + 
  scale_colour_manual(values=cbPalette) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4

#Is parochial social learning correlated with social learing reliance? 
#Plot for theta = 180, parochial social learning vs. social learning reliance
# for all values of R
df <- mydata[which(mydata$strategies == "UL&CB" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5 & mydata$theta == 180), ] 
df.mean <- df %>% group_by(ID_corr) %>% summarise_each(funs(mean))

ggplot(df, aes(x = mean_social_final, y = mean_parochial_final, color=factor(ID_corr))) + 
  geom_point(size = 2, alpha = 0.6) + #, shape=16) +
  scale_x_continuous(limits=c(0, 1)) +
  scale_y_continuous(limits=c(0, 1)) +
  labs(x =expression(paste("social learning reliance")), y="parochial social learning", color="R") + 
  scale_colour_manual(values=cbPalette) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.position = c(0.88, .21))  + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4


#Plot the relationship between success bias and parochialism 
#For all R, theta = 180.  
df <- mydata[which(mydata$strategies == "UL&CB" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5 & mydata$theta == 180), ] 
df.mean <- df %>% group_by(ID_corr, mean_parochial_final) %>% summarise_each(funs(mean))

ggplot(df, aes(x = prop_conformist_final, y = mean_parochial_final, color=factor(ID_corr))) + 
  geom_point(size = 2, alpha = 0.6) + #, shape=16) +
  scale_x_continuous(limits=c(0, 1)) +
  scale_y_continuous(limits=c(0, 1)) +
  labs(x =expression(paste("proportion conformist")), y="parochial social learning", color="R") + 
  scale_colour_manual(values=cbPalette) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4



#---------------------------------------------
# 4B. Learning Biases -- Success Bias
#---------------------------------------------

rm(list = ls()) 
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
mydata <- read.csv("./analysis_3_4.csv", skip = 0, header = TRUE, sep = ",")
#N = {50, 200}, n = {1, 5, 15}, sigma_l = [0: 0.01: 0.5], f = {0.5, 0.7, 0.9}, strategies = {UL&CB, UL&PB}

#SUCCESS-BIAS
df <- mydata[which(mydata$strategies == "UL&PB" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5), ] 
df.mean <- df %>% group_by(theta, ID_corr) %>% summarise_each(funs(mean))
#will return a warning because the strategy type is non-numeric. It's fine. 

#which social learning strategies evolve
ggplot(df, aes(x = theta, y = prop_payoff_final, color=factor(ID_corr))) + 
  geom_point(size = 1, alpha = 0.2) + #, shape=16) +
  geom_line(data=df.mean, aes(x = theta, y = prop_payoff_final, color=factor(ID_corr)), linewidth=1, linetype="solid") +
  scale_x_continuous(limits=c(0, 180), breaks=c(0, 45, 90, 135, 180)) +
  scale_y_continuous(limits=c(0, 1)) +
  labs(x =expression(paste("distance between adaptive traits, ",theta)), y="proportion payoff-biased social learning", color="R") + 
  scale_color_viridis(discrete = TRUE,option="plasma", direction = -1) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4.5

df <- mydata[which(mydata$strategies == "UL&PB" &  mydata$N == 50  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5),]  
df.mean <- df %>% group_by(theta, ID_corr) %>% summarise_each(funs(mean))
#evolution of parochial social learning
ggplot(df, aes(x = theta, y = mean_parochial_final, color=factor(ID_corr))) + 
  geom_point(size = 1, alpha = 0.2) + #, shape=16) +
  geom_line(data=df.mean, aes(x = theta, y = mean_parochial_final, color=factor(ID_corr)), linewidth=1, linetype="solid") +
  scale_x_continuous(limits=c(0, 180), breaks=c(0, 45, 90, 135, 180)) +
  labs(x =expression(paste("distance between adaptive traits, ",theta)), y="parochial social learning", color="R") + 
  scale_color_viridis(discrete = TRUE) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4.5

#look at all the runs for social learning reliance
df <- mydata[which(mydata$strategies == "UL&PB" &  mydata$N == 50  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5),]
df.mean <- df %>% group_by(theta, ID_corr) %>% summarise_each(funs(mean))
#evolution of  social learning reliance
ggplot(df, aes(x = theta, y = mean_social_final, color=factor(ID_corr))) +  
  geom_point(size = 1, alpha = 0.2) + #, shape=16) +
  geom_line(data=df.mean, linewidth=1, linetype="solid") +
  scale_x_continuous(limits=c(0, 180), breaks=c(0, 45, 90, 135, 180)) +
  scale_y_continuous(limits=c(0, 1)) +
  labs(x =expression(paste("distance between adaptive traits, ",theta)), y="social learning reliance", color="R") + 
  scale_color_viridis(discrete = TRUE) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4.5



#Is parochial social learning correlated with social learing reliance? 
#Plot for theta = 180, parochial social learning vs. social learning reliance
# for all values of R
df <- mydata[which(mydata$strategies == "UL&PB" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5 & mydata$theta == 180), ] 
df.mean <- df %>% group_by(ID_corr) %>% summarise_each(funs(mean))

ggplot(df, aes(x = mean_social_final, y = mean_parochial_final, color=factor(ID_corr))) + 
  geom_point(size = 2, alpha = 0.6) + #, shape=16) +
  scale_x_continuous(limits=c(0, 1)) +
  scale_y_continuous(limits=c(0, 1)) +
  labs(x =expression(paste("social learning reliance")), y="parochial social learning", color="R") + 
  scale_colour_manual(values=cbPalette) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.position = c(0.88, .21))  + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4

#Is parochial social learning correlated with social learing reliance? 
#Plot for R = 1, parochial social learning vs. social learning reliance
# for theta = {0, 45, 90, 135, 180}
df <- mydata[which(mydata$strategies == "UL&PB" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5 & mydata$ID_corr == .5 & (mydata$theta == 0 | mydata$theta <= 40 | mydata$theta == 90 | mydata$theta == 130 | mydata$theta == 180)), ] 
df.mean <- df %>% group_by(theta) %>% summarise_each(funs(mean))

ggplot(df, aes(x = mean_social_final, y = mean_parochial_final, color=factor(theta))) + 
  geom_point(size = 2, alpha = 0.6) + #, shape=16) +
  labs(x =expression(paste("social learning reliance")), y="parochial social learning", color="theta") + 
  scale_color_viridis(discrete = TRUE) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4


#Plot the relationship between success bias and parochialism 
#For all R, theta = 180.  
df <- mydata[which(mydata$strategies == "UL&PB" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5 & mydata$theta == 180), ] 
df.mean <- df %>% group_by(ID_corr, mean_parochial_final) %>% summarise_each(funs(mean))

ggplot(df, aes(x = prop_payoff_final, y = mean_parochial_final, color=factor(ID_corr))) + 
  geom_point(size = 2, alpha = 0.6) + #, shape=16) +
  scale_x_continuous(limits=c(0, 1)) +
  scale_y_continuous(limits=c(0, 1)) +
  labs(x =expression(paste("proportion payoff bias")), y="parochial social learning", color="R") + 
  scale_colour_manual(values=cbPalette) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4 (or 4.5)


#---------------------------------------------
# 4C. Learning Biases -- BOTH Conformity and Success Bias
#---------------------------------------------


rm(list = ls()) 
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
mydata <- read.csv("./analysis_3_4.csv", skip = 0, header = TRUE, sep = ",")
#N = {50, 200}, n = {1, 5, 15}, sigma_l = [0: 0.01: 0.5], f = {0.5, 0.7, 0.9}, strategies = {UL&CB, UL&PB}
df <- mydata[which(mydata$strategies == "ALLTHREE" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5 & mydata$ID_corr == 1), ] 
df.mean <- df %>% group_by(theta) %>% summarise_each(funs(mean))
#will return a warning because the strategy type is non-numeric. It's fine. 

#which social learning strategies evolve -
ggplot(df, aes(x = theta)) + 
  geom_point(aes(y = prop_payoff_final, color = "payoff-biased"), size = 1, alpha = 0.1) + #, shape=16) +
  geom_point(aes(y = prop_conformist_final, color = "conformist"), size = 1, alpha = 0.1) + #, shape=16) +
  geom_point(aes(y = prop_unbiased_final, color = "unbiased"), size = 1, alpha = 0.2) + #, shape=16) +
  geom_line(data=df.mean, aes(x = theta, y = prop_conformist_final, color = "conformist"), linewidth=1, linetype="solid") +
  geom_line(data=df.mean, aes(x = theta, y = prop_payoff_final, color = "payoff-biased"), linewidth=1, linetype="solid") +
  geom_line(data=df.mean, aes(x = theta, y = prop_unbiased_final, color = "unbiased"), linewidth=1, linetype="solid") +
  scale_colour_manual("", 
                      breaks = c("unbiased", "conformist", "payoff-biased"),
                      values = c("grey40", "darkorange", "turquoise3")) +
  scale_x_continuous(limits=c(0, 180), breaks=c(0, 45, 90, 135, 180)) +
  scale_y_continuous(limits=c(0, 1)) +
  labs(x =expression(paste("distance between adaptive traits, ",theta)), y="proportion payoff-biased social learning", color="R") + 
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 5

#Which strategy 
df <- mydata[which(mydata$strategies == "ALLTHREE" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5), ] 
df.mean <- df %>% group_by(theta, ID_corr) %>% summarise_each(funs(mean))
#which social learning strategies evolve #2
ggplot(df, aes(x = theta, y = prop_payoff_final, color=factor(ID_corr))) + 
  geom_point(size = 1, alpha = 0.2) + #, shape=16) +
  geom_line(data=df.mean, aes(x = theta, y = prop_payoff_final, color=factor(ID_corr)), linewidth=1, linetype="solid") +
  scale_x_continuous(limits=c(0, 180), breaks=c(0, 45, 90, 135, 180)) +
  scale_y_continuous(limits=c(0, 1)) +
  labs(x =expression(paste("distance between adaptive traits, ",theta)), y="proportion payoff-biased social learning", color="R") + 
  scale_color_viridis(discrete = TRUE,option="plasma", direction = -1) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4.5


df <- mydata[which(mydata$strategies == "ALLTHREE" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5),] 
df.mean <- df %>% group_by(theta, ID_corr) %>% summarise_each(funs(mean))

#evolution of parochial social learning
ggplot(df, aes(x = theta, y = mean_parochial_final, color=factor(ID_corr))) + 
  geom_point(size = 1, alpha = 0.2) + #, shape=16) +
  geom_line(data=df.mean, aes(x = theta, y = mean_parochial_final, color=factor(ID_corr)), linewidth=1, linetype="solid") +
  scale_x_continuous(limits=c(0, 180), breaks=c(0, 45, 90, 135, 180)) +
  labs(x =expression(paste("distance between adaptive traits, ",theta)), y="parochial social learning", color="R") + 
  scale_color_viridis(discrete = TRUE) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
   theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4.5

#look at all the runs for social learning reliance
df <- mydata[which(mydata$strategies == "ALLTHREE" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5),] # & mydata$mu_p > 0), ] 
df.mean <- df %>% group_by(theta, ID_corr) %>% summarise_each(funs(mean))
#evolution of  social learning reliance
ggplot(df, aes(x = theta, y = mean_social_final, color=factor(ID_corr))) +  
  geom_point(size = 1, alpha = 0.2) + #, shape=16) +
  geom_line(data=df.mean, linewidth=1, linetype="solid") +
  scale_x_continuous(limits=c(0, 180), breaks=c(0, 45, 90, 135, 180)) +
  scale_y_continuous(limits=c(0, 1)) +
  labs(x =expression(paste("distance between adaptive traits, ",theta)), y="social learning reliance", color="R") + 
  scale_color_viridis(discrete = TRUE) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4.5



#Is parochial social learning correlated with social learing reliance? 
#Plot for theta = 180, parochial social learning vs. social learning reliance
# for all values of R
df <- mydata[which(mydata$strategies == "ALLTHREE" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5 & mydata$theta == 180), ] 
df.mean <- df %>% group_by(ID_corr) %>% summarise_each(funs(mean))

ggplot(df, aes(x = mean_social_final, y = mean_parochial_final, color=factor(ID_corr))) + 
  geom_point(size = 2, alpha = 0.6) + #, shape=16) +
  scale_x_continuous(limits=c(0, 1)) +
  scale_y_continuous(limits=c(0, 1)) +
  labs(x =expression(paste("social learning reliance")), y="parochial social learning", color="R") + 
  scale_colour_manual(values=cbPalette) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.position = c(0.88, .21))  + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4

#Is parochial social learning correlated with social learing reliance? 
#Plot for R = 1, parochial social learning vs. social learning reliance
# for theta = {0, 45, 90, 135, 180}
df <- mydata[which(mydata$strategies == "ALLTHREE" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5 & mydata$ID_corr == 1 & (mydata$theta == 0 | mydata$theta <= 40 | mydata$theta == 90 | mydata$theta == 130 | mydata$theta == 180)), ] 
df.mean <- df %>% group_by(theta) %>% summarise_each(funs(mean))

ggplot(df, aes(x = mean_social_final, y = mean_parochial_final, color=factor(theta))) + 
  geom_point(size = 2, alpha = 0.6) + #, shape=16) +
  labs(x =expression(paste("social learning reliance")), y="parochial social learning", color="theta") + 
  scale_color_viridis(discrete = TRUE) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4


#Plot the relationship between success bias and parochialism 
#For all R, theta = 180.  
df <- mydata[which(mydata$strategies == "ALLTHREE" &  mydata$N == 200  & mydata$n == 5 & mydata$sigma_l == 0.3 & mydata$f == 0.5 & mydata$theta == 180), ] 
df.mean <- df %>% group_by(ID_corr, mean_parochial_final) %>% summarise_each(funs(mean))

ggplot(df, aes(x = prop_payoff_final, y = mean_parochial_final, color=factor(ID_corr))) + 
  geom_point(size = 2, alpha = 0.6) + #, shape=16) +
  scale_x_continuous(limits=c(0, 1)) +
  scale_y_continuous(limits=c(0, 1)) +
  labs(x =expression(paste("proportion payoff bias")), y="parochial social learning", color="R") + 
  scale_colour_manual(values=cbPalette) +
  theme_bw() +
  theme(panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(),
        panel.background = element_rect(colour = "black", linewidth=1)) + 
  theme(legend.text=element_text(size=9)) + 
  theme(legend.key.height=unit(.8,"line"))
#3.5 x 4 (or 4.5)





