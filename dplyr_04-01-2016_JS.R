##################################################
# Introducing 'dplyr' package
# April 1, 2016
# Jihyun Shin 
##################################################

# Using `dplyr` library
# `dplyr` is a package for data frame manipulation. Some of the key functions include:
#       * `select()`: Subset of columns.
#       * `filter()`: Subset of rows.
#       * `arrange()`: Reorders rows.
#       * `mutate()`: Adding columns to existing data.
#       * `summarise()`: Summarizing data set.
# Remember that select-> for 'variables'(column), filter ->'rows'



# First, we are going to be using the "Houston flights data" in the `hflights` package.
rm(list = ls()) 
library(dplyr)
library(hflights)

?hflights

data<-tbl_df(hflights)
data


#############
# select()
#############
# basic syntax:  select(data, Var1, Var2, ...)
select(data, ActualElapsedTime, AirTime, ArrDelay, DepDelay)

# Return a copy of hflights containing the columns Origin up to Cancelled
select(data, origin:cancelled)

# Return columns Year up to and including DayOfWeek, columns ArrDelay up to and including Diverted.
select(data, - (DepTime:AirTime))
select(data, c(Year:DayOfWeek, ArrDelay:Diverted)) # the same output

# Introducing the Piping Operator `%>%`
# This will make the `R` code very fast, because we are passing it on to a new function.
data%>%
        select(~(DepTime:AirTime)) 



#############
# mutate(): mutate () creates new columns which are added to a copy of the dataset.
#############

# Create a variable to the existing data frame called GroundTime which adds TaxiIn time and TaxiOut time
d1<-mutate(data, GroundTime=TaxiIn+TaxiOut)

# Now, select only three variables in the data frame: TaxiIn, TaxiOut, GroundTime
d2<-select(d1,TaxiIn, TaxiOut, GroundTime)

### or (piping)
d4<- data %>% 
        mutate(GroundTime=TaxiIn+TaxiOut) %>%
        select(TaxiIn, TaxiOut, GroundTime)


#############
# filter(): mutate () creates new columns which are added to a copy of the dataset.
#############
# R comes with a set of logical operators that you can use to extract rows with filter()
# • x<y,TRUEifxislessthany
# • x<=y,TRUEifxislessthanorequaltoy
# • x==y,TRUEifxequalsy
# • x!=y,TRUEifxdoesnotequaly
# • x>=y,TRUEifxisgreaterthanorequaltoy
# • x>y,TRUEifxisgreaterthany
# • x%in%c(a,b,c),TRUEifxisinthevectorc(a,b,c)


# All flights that traveled 3000 miles or more.
f1 <- filter(data, Distance >= 3000)

# All flights flown by one of JetBlue, Southwest, or Delta #airlines
f2 <- filter(data, UniqueCarrier %in% c("AA",
                                            "Southwest",
                                            "Delta"))

# All flights where taxiing took longer than flying
f3 <- filter(hflights, TaxiIn + TaxiOut > AirTime)

# all flights that departed before 5am or arrived after 10pm.
f4 <- filter(hflights, DepTime < 500 | ArrTime > 2200)

# all flights that departed late but arrived ahead of schedule
f5 <- filter(hflights, DepDelay > 0 & ArrDelay < 0) 

# all cancelled weekend flights
f6 <- filter(hflights, DayOfWeek %in% c(6,7) & Cancelled == 1)


#############
# arrange(): reorders the rows according to single or multiple variables.
#############
# Arrange  by departure delays
a1 <- arrange(data, DepDelay)

#By default, arrange() arranges the rows from smallest to largest. 
# Rows with the smallest value of the variable will appear at the top of the data set.

# Arrange by decreasing departure delays
a2 <- arrange(data, desc(DepDelay))

# Arrange data so that cancellation reasons are grouped
a3 <- arrange(dtc, CancellationCode)

# Arrange according to carrier and decreasing departure delays
a1 <- arrange(hflights, UniqueCarrier, desc(DepDelay))


#############
# summarise(): reorders the rows according to single or multiple variables.
#############

# Determine the shortest and longest distance flown and
# save statistics to min_dist and max_dist resp.
s1 <- summarise(data, min_dist = min(Distance), max_dist = max(Distance))

# Determine the longest distance for diverted flights,
# save statistic to max_div. 
# one-liner
s2 <- summarise(filter(data, Diverted==1), max_div = max(Distance))

# piping 
s3 <- data %>% 
        filter(Diverted==1) %>% 
        summarise(max_div=max(Distance))

# Calculate summary statistics for flights that 
# have an ArrDelay that is not NA
temp1 <- filter(hflights, !is.na(ArrDelay))
s1 <- summarise(temp1, earliest = min(ArrDelay),
                average = mean(ArrDelay), latest = max(ArrDelay), sd = sd(ArrDelay))



# Some other aggregate functions: 
#• nth(x, n) - The nth element of vector x.
#• n() - The number of rows in the data.frame or group of observations that summarise() describes. 
#• n_distinct(x) - The number of unique values in vector x.

#Create a table with the following variables (and
# variable names): the total number of observations in
# hflights (n_obs), the total number of carriers that appear
# in hflights (n_carrier), the total number of destinations
# that appear in hflights (n_dest), and the destination of
#the flight that appears in the 100th row of
# hflights (dest100).
s1 <- summarise(hflights, n_obs = n(),
                n_carrier = n_distinct(UniqueCarrier),
                n_dest = n_distinct(Dest), dest100 = nth(Dest, 100))



###### Some practice with Pipe Operator %>% 
# Take the hflights data set and then ... Add a variable
# named diff that is the result of subtracting TaxiIn from
# TaxiOut, and then ...
# Pick all of the rows whose diff value does not equal NA, and
# then ...
# Summarise the data set with a value named avg that is the
# mean diff value.Store the result in the variable p.
p1 <- hflights
p2 <- mutate(p1, diff = TaxiOut - TaxiIn) p3 <- filter(p2, !is.na(diff))
p <- summarise(p3, avg = mean(diff))

### OR, piped!
p <- hflights %>%
        mutate(diff = TaxiOut - TaxiIn) %>% filter(!is.na(diff)) %>% summarise(avg = mean(diff))


###############
##### group_by: this does extra step than arrange function
###############
# group_by() lets you define groups within your data set. 
# Its influence becomes clear when calling summarise() on a grouped dataset: 
# summarizing statistics are calculated for the different groups separately.



# Use group_by() and summarise() to compare the individual
# carriers. For each carrier, count the total number of
# flights
# flown by the carrier (n_flights), the total number of
# cancelled flights (n_canc), the percentage of cancelled
# flights (p_canc), and the average arrival delay of the
# flights whose delay does not equal NA (avg_delay). Once
# you've calculated these results, arrange() the carriers from
# low to high by their average arrival delay. Use percentage
# of flights cancelled to break any ties. Which airline scores
# best based on these statistics?

data %>% 
        group_by(UniqueCarrier) %>% 
        summarise(n_flights = n(), 
                  n_canc = sum(Cancelled == 1),
                  p_canc = mean(Cancelled == 1) * 100, 
                  avg_delay = mean(ArrDelay, na.rm = TRUE)) %>%
        arrange(avg_delay, p_canc)


data %>% 
        summarise(n_flights = n(), 
                  n_canc = sum(Cancelled == 1),
                  p_canc = mean(Cancelled == 1) * 100, 
                  avg_delay = mean(ArrDelay, na.rm = TRUE)) %>%
        arrange(avg_delay, p_canc)

