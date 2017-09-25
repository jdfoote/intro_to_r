# FILES FOR TODAY
#   https://github.com/j3schaue/dplyr_workshop




install.packages('dplyr')
library(dplyr)

###----Load the data
install.packages("nycflights13")
library(nycflights13)

head(flights)
head(airlines)
head(weather)
head(planes)



###----What does this do?
tt = flights[((flights$sched_dep_time > 1600 & flights$carrier > "AA")|
                (flights$sched_dep_time > 1200 & flights$carrier=="UA")), 
             c(1:3, 6, 9:10)]

###----How would we get the records for each plane that appears in one row? 
###     Exactly two rows?



###----------------------------------------------------------------------------###
### Single-table Verbs
###----------------------------------------------------------------------------###

###----The basics: filter and select
# get the records for the United Airlines
tmp = filter(flights, carrier=="UA")
head(tmp)

# get rows 5-20
slice(flights, 5:20)

# get carrier, departure delays, and arrival delays
tmp = select(flights, carrier, dep_delay, arr_delay)
head(tmp)

# get carrier and arrival delays, but rename arrival delays.
tmp = select(flights, carrier, minlate=arr_delay)
head(tmp)

# just rename arrival delays, but keep all columns
tmp2 = rename(flights, arrlate=arr_delay)
names(tmp2)

###-----arrange 
# order tmp by earliest flight
arrange(tmp, minlate)

# order tmp by latest flight
arrange(tmp, desc(minlate))

# order weather by fastest wind gust and lowest temperature
ww = arrange(weather, desc(wind_gust), temp)
head(select(ww, temp, wind_gust))

###------distinct
# get the tailnumber of each unique plane in the flights data
pl = distinct(flights, tailnum)
head(pl)

# get the distinct flight and carrier pairs
plal = distinct(flights, carrier, tailnum)
head(plal)


###------mutate
# Add a column to indicate that a flight arrived nearly ontime (within 10 min)
fl = mutate(flights, arr_ontime = as.integer(abs(arr_delay) < 10))
head(select(fl, carrier, arr_time, arr_delay, arr_ontime))

# Get a column that sums the arrival and departure delays
dels = transmute(flights, tdel = arr_delay + dep_delay)
dels


###------summarize
# Get the mean arrival and departure delays
summarize(flights, dep=mean(dep_delay, na.rm=T), arr=mean(arr_delay, na.rm=T))

# get the standard deviations of each
summarize(flights, sd_dep=sd(dep_delay, na.rm=T), sd_arr=sd(arr_delay, na.rm=T))

###------sample
# sample 2 rows from the airlines data
sample_n(airlines, 2)
sample_frac(airlines, 2/7)


###-------------END OF PART 1
### Exercsies


###----------------------------------------------------------------------------###
### Combining single-table verbs
###----------------------------------------------------------------------------###
# get airline, departure and arrival delays from flights that land late
select(filter(flights, arr_delay > 0), carrier, dep_delay, arr_delay)

# departure and arrival delays for UA flights taht land > 5 mintues late
filter(select(flights, carrier, dep_delay, arr_delay), carrier=="UA" &  arr_delay > 5)


###----Piping
latearr = flights %>% 
            filter(arr_delay > 5) %>% 
            select(carrier, dep_delay, arr_delay)

# Compare am and pm flights for delays
am_stats = flights %>%
              filter(sched_arr_time < 1200) %>%
              summarize(mn_arr_delay = mean(arr_delay, na.rm=T),
                        mn_dep_delay = mean(dep_delay, na.rm=T),
                        p_delay = mean(as.integer(dep_delay > 5), na.rm=T))

pm_stats = flights %>%
  filter(sched_arr_time >= 1200) %>%
  summarize(mn_arr_delay = mean(arr_delay, na.rm=T),
            mn_dep_delay = mean(dep_delay, na.rm=T),
            p_delay = mean(as.integer(dep_delay > 5), na.rm=T))


am_stats
pm_stats
am_stats - pm_stats

###-------------END OF PART 2
### Exercsies



###----------------------------------------------------------------------------###
### Grouping
###----------------------------------------------------------------------------###
flights %>% group_by(carrier) %>% tally() %>% arrange(desc(n))
flights %>% group_by(tailnum) %>% tally() %>% arrange(desc(n))

# mean age of plane by manufacturer
planes %>% 
  group_by(manufacturer) %>% 
  summarize(mn_age = mean(2017 - year, na.rm=T), mn_size=mean(seats, na.rm=T)) %>%
  arrange(mn_age)

# weather by airport
weather %>% 
  group_by(origin) %>%
  summarize(max_gust = max(wind_gust, na.rm=T),
            mn_wind = mean(wind_speed, na.rm=T),
            mn_tmp = mean(temp, na.rm=T),
            min_vis = min(visib, na.rm=T),
            max_vix = max(visib, na.rm=T),
            mn_vis = mean(visib, na.rm=T))


###--------END OF PART 3
### Exercises



###----------------------------------------------------------------------------###
### Two-table Verbs: Joins 
###----------------------------------------------------------------------------###

### Plane age by carrier (2 ways)
fl_pl = left_join(flights, planes, by="tailnum")
fl_pl %>% 
  group_by(carrier) %>%
  summarize(mn_age = mean(2017 - year.y, na.rm=T)) %>%
  arrange(mn_age)

flights %>% 
  mutate(date = as.Date(paste(year, month, day, sep="-"))) %>%
  select(-year, -month, -day) %>%
  left_join(planes, by="tailnum") %>%
  group_by(carrier) %>%
  summarize(mn_age = mean(2017 - year, na.rm=T)) %>%
  arrange(mn_age)


### Joins when columns have different names
flights %>% arrange(dest) %>% distinct(dest) %>% slice(1:5)
airports$faa[88:94]

flapt1 = left_join(flights, airports, c("dest" = "faa"))
dim(flapt1)
names(flapt1)

flapt2 = left_join(airports, flights, c("faa" = "dest"))
dim(flapt2)
names(flapt2)

setdiff(names(flapt1), names(flapt2))

flapt3 = full_join(flights, airports, c("dest" = "faa"))
dim(flapt3)
flapt3 %>% filter(dest == "04G")


### Only planes that are flown by United or American
fl_uaaa = flights %>% filter(carrier %in% c("UA", "AA"))
planes_uaaa = semi_join(planes, fl_uaaa, by="tailnum")

pl_uaaa = flights %>% filter(carrier %in% c("UA", "AA")) %>%
                semi_join(planes, ., by="tailnum")

### Only planes that are not flown by United or American
pl_uaaa = flights %>% filter(carrier %in% c("UA", "AA")) %>%
                anti_join(planes, ., by="tailnum")
