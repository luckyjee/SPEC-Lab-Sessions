##################################################
# Introducing 'ggplot2' package
# April 1, 2016
# Jihyun Shin 
##################################################

# ggplot2 is meant to be an implementation of the Grammar of Graphics, hence gg-plot. 
# The basic notion is that there is a grammar to the composition of graphical components in statistical graphics, 
# and by direcly controlling that grammar, 
# you can generate a large set of carefully constructed graphics tailored to your particular needs.


# To create a new plot: ggplot(df, aes(x, y, )) + geom().

rm(list=ls())
##############
# Bar Graphs
##############

library(gcookbook) 
library(ggplot2)

?diamonds
ggplot(diamonds, aes(x=cut)) + geom_bar()

#If we use a continous variable on the x-axis, then we will get a histogram:
ggplot(diamonds, aes(x = carat)) + geom_bar()

ggplot(diamonds, aes(x = carat)) + 
        geom_bar(fill="lightblue", color="red")


#The most basic bar graphs have one categorical variable on the x-axis and one continous variable on the y-axis. 
#Sometimes you want to use another categorical variable to divide up the data, 
#in addition to the variable on the y-axis. 
#You can produce a grouped bar plot by mapping that variable to fill, 
#which represents the fill color of the bars. 
#You must also use position = "dodge", which tells the bars to “dodge” each other horizontally; 
#if you don’t, you will end up with a stacked bar plot.

ggplot(diamonds, aes(x=cut, fill = clarity)) + 
        geom_bar(position ="dodge", color = "black")

## To have spaces between the bars. The default value is 0.9 
ggplot(diamonds, aes(x=cut, fill = clarity)) +
geom_bar(position =position_dodge(0.99))

# Horizontal Bar Charts
ggplot(diamonds, aes(x=cut, fill = clarity)) +
        geom_bar(position =position_dodge(0.99))+
        coord_flip()


##############
# Dot Plot
##############
#Dot Plots are used when we have a lot of categories and we want to reduce visual clutter 
# to make the plot easier to read. To do so, we will use geom_point().

# tophitters2001
?tophitters2001
# We will just focus on three variables: name and avg, and the top 25 hitters.
tophit <- tophitters2001[1:25, c('name', 'avg')]
ggplot(tophit, aes(x = avg, y=name)) + geom_point()

#names are sorted alphabitically
#Let's sort by the value of the continous variable on the horizontal axis
ggplot(tophit, aes(x = avg, y=reorder(name, avg))) + geom_point(size = 3)


##############
# Histrograms from Grouped Data
##############

library(MASS)

ggplot(birthwt, aes(x = bwt)) +
        geom_histogram(fill = "white", colour = "black") + 
        facet_grid(smoke~.)

ggplot(birthwt, aes(x = bwt)) +
        geom_histogram(fill = "white", colour = "black") +
        facet_grid(.~smoke)


# Change levels of categorical variable
data <- birthwt
data$smoke <- as.factor(data$smoke) 
levels(data$smoke) <- c("No Smoke", "Smoke")

ggplot(data, aes(x = bwt)) +
        geom_histogram(fill = "white", colour = "black") + 
        facet_grid(smoke~.)

# Give a title
ggplot(data, aes(x = bwt)) +
        geom_histogram(fill = "white", colour = "black") + 
        facet_grid(smoke~.) +
        ggtitle("Birth Weight")

# we can map the grouping variable to fill.
ggplot(data, aes(x = bwt, fill = smoke)) + 
        geom_histogram()

# It's difficult to see the distribution of each group. 
# Instead, we can use position = "identity" and alpha blending to make the bars visible using alpha = 0.4.


## stat_bin: binwidth defaulted to range/30. Use 'binwidth = x' to adjust this.
ggplot(data, aes(x = bwt, fill = smoke)) + 
        geom_histogram(position = "identity", alpha = 0.4)

##############
# Density Curve: distriution of a continous variable
##############
# geom_line(stat = "density")

?faithful
ggplot(faithful, aes(x = waiting)) + 
        geom_line(stat = "density")


#amount of smoothing depends on the kernel bandwidth: the larger the bandwidth, the more smoothing there is
ggplot(faithful, aes(x = waiting)) +
        geom_line(stat = "density", adjust = 0.25, color = "red") + 
        geom_line(stat = "density") +
        geom_line(stat = "density", adjust = 2, color = "blue")

#expand the x limits as follows:
ggplot(faithful, aes(x = waiting)) +
        geom_line(stat = "density", adjust = 0.25, color = "red") + 
        geom_line(stat = "density") +
        geom_line(stat = "density", adjust = 2, color = "blue") + 
        xlim(35, 105)


##############
# Box Plot
##############
mode(data$race)
data$race<- as.factor(data$race) 
levels(data$race) <- c("White", "Black", "Other")

ggplot(data, aes(x = race, y = bwt)) + 
        geom_boxplot()



ggplot(data, aes(x = race, y = bwt)) +
        geom_boxplot(width = 0.5, outlier.size = 5) + 
        coord_flip()


#make a boxplot for all observations for bwt without looking at each group seperately: x=1
#get rid of the x-axis tick markers and labels
ggplot(birthwt, aes(x =1, y = bwt)) + 
        geom_boxplot() + 
        scale_x_continuous(breaks = NULL)+ 
        xlab("")


##############
# Line Graph
##############

library(gcookbook)
ggplot(worldpop, aes(x = Year, y = Population)) +
        geom_line() + 
        geom_point()

?ToothGrowth
library(plyr)
tg <- ddply(ToothGrowth, c("supp", "dose"), summarise, length= (mean(len))) 
tg


ggplot(tg, aes(x = dose, y = length, colour = supp)) + geom_line()


ggplot(tg, aes(x = dose, y = length, linetype = supp)) + geom_line()


ggplot(tg, aes(x = dose, y = length,  group=supp)) + 
        geom_line(color = "lightblue", size = 2, linetype = "dashed")


ggplot(tg, aes(x = dose, y = length,  group=supp)) + 
        geom_line(color = "lightblue", size = 2, linetype = "dashed")+
        geom_point(size = 7, shape = 21)



# find out the different point shapes (25 different shapes)
pts = data.frame(x = 1:25, y = rep(10, 25))
ggplot(pts, aes(x = factor(x), y = y)) + geom_point(shape = 1:25, size = 4)

##############
# Stacked Graph
##############

ggplot(uspopage, aes(x = Year, y = Thousands, fill = AgeGroup)) + geom_area()

#The default order of the legend is opposite of the stacking order. 
#You can reverse the stacking order using order = desc(AgeGroup)

library(plyr) # for desc()
ggplot(uspopage, aes(x = Year, y = Thousands, fill = AgeGroup, order = desc(AgeGroup))) +
        geom_area(color = "black", size = 0.2, alpha = 0.4) + ylab("Population Size (in thousands)")
