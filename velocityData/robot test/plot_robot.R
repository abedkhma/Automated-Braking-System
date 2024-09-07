library(ggplot2)
library(data.table)
library(tidyr)

read_robot_data_csv <- function(path) {
  files <- list.files(path, full.names = TRUE)
  files <- files[endsWith(files, "csv")]
  names(files) <- basename(files)
  tables <- lapply(files, fread)
  dt <- rbindlist(tables, idcol = 'filepath')
  dt[,time := (1:.N), by=filepath]
  dt[, velocity := `Amplitude - Plot 0`]
  return(dt)
}

path_20 <- '~/abdulla_thesis/robot_data/20_speed_clean/'
path_50 <- '~/abdulla_thesis/robot_data/50_speed_clean/'

dt_20 <- read_robot_data_csv(path_20)
dt_50 <- read_robot_data_csv(path_50)

dt_20_mean <- dt_20[, .(mean_velocity=mean(velocity, na.rm=T), sd=sd(velocity, na.rm=T)/.N), by=time]
n_zeros_before <- 100
n_zeros_after <- 1000
dt_20_mean[, time:=time+n_zeros_before]
zero_dt_before <- data.table(time=1:n_zeros_before, mean_velocity=rep(0, n_zeros_before), sd=rep(0, n_zeros_before))
zero_dt_after <- data.table(time=(dt_20_mean[,max(time)]+1):(dt_20_mean[,max(time)]+n_zeros_after), mean_velocity=rep(0, n_zeros_after), sd=rep(0, n_zeros_after))
dt_20_mean <- rbind(zero_dt_before, dt_20_mean, zero_dt_after)

dt_50_mean <- dt_50[, .(mean_velocity=mean(velocity, na.rm=T), sd=sd(velocity, na.rm=T)/.N), by=time]
n_zeros_before <- 100
n_zeros_after <- 1000
dt_50_mean[, time:=time+n_zeros_before]
zero_dt_before <- data.table(time=1:n_zeros_before, mean_velocity=rep(0, n_zeros_before), sd=rep(0, n_zeros_before))
zero_dt_after <- data.table(time=(dt_50_mean[,max(time)]+1):(dt_50_mean[,max(time)]+n_zeros_after), mean_velocity=rep(0, n_zeros_after), sd=rep(0, n_zeros_after))
dt_50_mean <- rbind(zero_dt_before, dt_50_mean, zero_dt_after)



mysize <- 10
mytheme <- theme_bw() + # we start with bw theme
  theme(
    axis.title = element_text(size=mysize),
    axis.text = element_text(size=mysize),
    legend.text = element_text(size=mysize),
    legend.title=element_blank()
  ) # and override some parameters values
# 47.298, 68.049
annotations <- data.frame(
  xpos = c(Inf),
  ypos =  c(Inf),
  annotateText = c("F=68.049 N"),
  hjustvar = c(1.1) ,
  vjustvar = c(1.5)) #<- adjust

ggplot(data=dt_50_mean, aes(x=time/1000, y=mean_velocity)) +
  geom_line() +
  geom_ribbon(aes(ymin = mean_velocity-1.96*sd, ymax = mean_velocity+1.96*sd), alpha=.2) +
  xlab("time (s)") +
  ylab("velocity (m/s)") +
  geom_text(data=annotations,aes(x=xpos,y=ypos,hjust=hjustvar,vjust=vjustvar,label=annotateText)) +
  ylim(0, 0.42) +
  scale_x_continuous(breaks = seq(0, 1.3, by = 0.25), limits=c(0, 1.3)) +
  mytheme
