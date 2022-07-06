# Run-Time Environment:  	R version 4.0.2 & R Studio 2022.02.3
# Author:				          Laura Kervezee (Leiden University Medical Center)
# Contact:                laurakervezee@gmail.com
# Purpose:    			      Make double plotted actogram from iPhone stepcount data
# Datafile used:			    export.xml from iPhone
#
# Note:                   This script is only intended for making a pretty looking double-plotted 'actogram' based on iPhone step count data. 
#                         Originally it was used as a goodbye gift, printed on aluminum, for a graduate student who was leaving the lab. 
#                         It has no scientific purpose and should not be used as such.
#
# License:                CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/ - you're free to share and adapt this code under the condition that you give appropriate credit)
#                         If you end up printing the actogram and put it on your wall or give it as a gift to someone, please take a picture and send it to me (laurakervezee@gmail.com) :-)
       
#Packages
library(tidyverse)
library(lubridate)
library(XML)

#Name (used later for file name)-----
name <- "XYZ"

#Indicate time window and time zone for actogram-----
#NOTE: step count seems to have been stored at low resolution with older iPhone models or older iPhone versions 
#as a result, the actogram may not look good when using older iPhone data (n=1 observation for data pre 2019)
date_from <- "2021-05-01" #starting date of actogram
date_to <- "2022-04-30" #end date of actogram

timezone <- "CET"
 
#Convert the input xml file to a data frame-----
input_data <- xmlParse("export.xml")
dat <- as_tibble(XML:::xmlAttrsToDataFrame(input_data["//Record"]))


#Data processing-----
#take only step count data & convert time to decimal time
dat_step <- dat %>% filter(type == 'HKQuantityTypeIdentifierStepCount') %>% 
  #dates column to date-type and add columns with date and decimal clock time
  mutate(datetime_start = ymd_hms(startDate, tz=timezone), #tz specification to get times in correct time zone & DST
         datetime_end = ymd_hms(endDate, tz=timezone),
         date_start = as.Date(datetime_start),
         date_end = as.Date(datetime_end),
         dectime_start = as.numeric(local_time(datetime_start, units="hours")),
         dectime_end = as.numeric(local_time(datetime_end, units="hours")),
         value = as.numeric(value)) %>% 
  select(startDate, datetime_start, datetime_end, date_start, date_end, dectime_start, dectime_end, value)


#select all data within given time frame
dat_step_sel <- dat_step %>% filter(date_start >= date_from & date_end <= date_to)

#make 10min time bins
dat_step_sel_summ <- dat_step_sel %>% mutate(dectime_startbin = round(dectime_start*6)/6,
                                             dectime_endbin = dectime_startbin+1/6) %>% 
  group_by(date_start, date_end, dectime_startbin, dectime_endbin) %>% 
  summarize(datetime_start = min(datetime_start),
            datetime_end = max(datetime_end),
            dectime_start = min(dectime_start),
            dectime_end = max(dectime_end), 
            value = sum(value),
            value_cap = ifelse(value > 1, 1, value)) 

#duplicate data for double plotting
dat_step_sel_summ_double <- dat_step_sel_summ %>% mutate(date_start = date_start-1,
                                                         dectime_startbin = dectime_startbin + 24,
                                                         dectime_endbin = dectime_endbin + 24) %>% 
  filter(date_start >= date_from)

dat_plot <- bind_rows(dat_step_sel_summ %>% filter(date_end < date_to), 
                      dat_step_sel_summ_double)

#Make actogram-----
pl_act <- ggplot(dat_plot, aes(xmin=dectime_startbin, xmax=dectime_endbin, ymin=-Inf, ymax=value_cap))+theme_bw()+
  facet_grid(date_start~., switch="y")+
  geom_rect(fill="black")+
  scale_x_continuous(breaks=seq(from=0, to=48, by=6), expand=c(0,0))+
  coord_cartesian(ylim=c(0,1.1), xlim=c(0,48), clip="off")+
  labs(x=NULL, y=NULL)+
  theme(axis.text.x = element_blank(), axis.title.x = element_text(size = 8), axis.ticks.x = element_blank(),
        axis.text.y = element_blank(), axis.title.y = element_text(size=8), axis.ticks.y = element_blank(),
        plot.background = element_blank(), panel.grid.major = element_blank(), panel.border = element_blank(),
        panel.grid.minor = element_blank(), panel.background = element_rect(fill="white"), axis.line = element_blank(), 
        strip.background = element_blank(), strip.text.y=element_blank(),legend.position="bottom",
        panel.spacing = unit(c(0), "lines"), plot.margin=unit(c(0,0,0,0), units="pt"))

#Save actogram-----
ggsave(pl_act, filename = paste0("pl_actogram_",name,"_",date_from,"_",date_to,".png"), dpi=600, width=30, height=45, units="cm")
ggsave(pl_act, filename = paste0("pl_actogram_",name,"_",date_from,"_",date_to,".pdf"), width=30, height=45, units="cm")
