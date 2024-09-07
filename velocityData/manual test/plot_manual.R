library(ggplot2)
library(data.table)
library(tidyr)

files <- list.files('~/abdulla_thesis/manual_data/', full.names = TRUE)
files <- files[endsWith(files, ".txt")]
names(files) <- basename(files)

tables <- lapply(files, fread)
dt <- rbindlist(tables, idcol = 'filepath')

dt <- as.data.table(separate(dt,
                             col = filepath, 
                             into = c("measurement", "brake")))

dt[, time:=V1]
dt[, magnitude:=V2]
dt[, V1:=NULL]
dt[, V2:=NULL]

dt_force <- dt[measurement == 'force']
dt_force[, formatted_time:=strptime(time, "%M:%OS")]
base_time_brake <- dt_force[brake=='brake', min(formatted_time)]
base_time_no_brake <- dt_force[brake=='no', min(formatted_time)]
dt_force[brake=='brake', unix_time:=as.numeric(difftime(formatted_time, base_time_brake, units = "secs"))]
dt_force[brake=='no', unix_time:=as.numeric(difftime(formatted_time, base_time_no_brake, units = "secs"))]

dt_velocity <- dt[measurement == 'velocity']
dt_velocity[, time:=as.numeric(time)]

max_force_brake = -dt_force[brake=='brake', min(magnitude)]
max_force_no_brake = -dt_force[brake=='no', min(magnitude)]

dt_velocity[brake == 'no', brake:='without brake'][brake == 'brake', brake:='with brake']

dt_velocity[brake == 'without brake', max_force:=max_force_no_brake][brake == 'with brake', max_force:=max_force_brake]

dt_velocity_brake <- dt_velocity[brake == 'with brake' & time >= 303 & time <= 936][, new_time:= 1:.N]
dt_velocity_no_brake <- dt_velocity[brake == 'without brake' & time >= 232 & time <= 513][, new_time:= 1:.N]

dt_velocity_new <- rbindlist(list(dt_velocity_brake, dt_velocity_no_brake), idcol = 'idcol')

mysize <- 10
mytheme <- theme_bw() + # we start with bw theme
  theme(
    axis.title = element_text(size=mysize),
    axis.text = element_text(size=mysize),
    legend.text = element_text(size=mysize),
    legend.title=element_blank()
  ) # and override some parameters values

ggplot(data=dt_velocity_new, aes(x=new_time*20/1000, y=magnitude)) +
  geom_line(aes(color=brake)) +
  xlab("time (s)") +
  ylab("velocity (m/s)") +
  scale_y_continuous(breaks = seq(0, 1.5, by = 0.1)) +
  geom_text(data = dt_velocity_new[brake == "with brake"], aes(x=Inf, y=Inf, label = paste0("F=", max_force_brake, " N")), hjust = 1.1, vjust = 1.4) +
  geom_text(data = dt_velocity_new[brake == "without brake"], aes(x=Inf, y=Inf, label = paste0("F=", max_force_no_brake, " N")), hjust = 1.1, vjust = 1.4) +
  facet_wrap(~brake, scales = 'free_x') +
  mytheme + theme(legend.position = "none")
