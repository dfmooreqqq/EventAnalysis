# Environment Setup -------------------------------------------------------
# Load packages.
packages <- c("gdata", "ggplot2", "plyr", "reshape2", "tm", "dplyr", "Matrix", "GDELTtools", "data.table",
              "date", "lubridate")
packages <- lapply(packages, FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
        install.packages(x)
        library(x, character.only = TRUE)
    }
})

# Set working directory
workingdir<-paste("C:\\Users", Sys.getenv("USERNAME"), "Documents\\Github\\EventAnalysis", sep = "\\")
setwd(workingdir)

DaysToGoBack = 5

#Define Dates
endstr = format(Sys.Date()-1, format="%Y-%m-%d")
startstr = format(Sys.Date()-DaysToGoBack-1, format="%Y-%m-%d")

# Load Data ---------------------------------------------------------------
#Actually load the data - ~10-20MB per day
GDeltData<-data.table(GetGDELT(start.date = startstr, 
         end.date = endstr, 
         data.url.root = "http://data.gdeltproject.org/events/",
         verbose = TRUE))

#Load event codes
eventcodes<-read.table("http://gdeltproject.org/data/lookups/CAMEO.eventcodes.txt", header=TRUE, sep="\t", as.is=TRUE, colClasses=c("character","character"))

    
# Format Tables------------------------------------------------------------
GDeltData$Date1<-parse_date_time(as.character(GDeltData$SQLDATE), order="ymd")
GDeltData<-merge(GDeltData, eventcodes, by.x = "EventRootCode", by.y = "CAMEOEVENTCODE")

USOnlyGDelt<-GDeltData[Actor2CountryCode=="USA",] # | Actor2CountryCode=="USA",]

EventsByDay<-GDeltData[,(COUNT = .N),by=c("Date1", "EventRootCode", "EVENTDESCRIPTION")]
EventsByCode<-GDeltData[,(COUNT = .N), by=c("EventRootCode", "EVENTDESCRIPTION")]
EventsByCode<-EventsByCode[order(-V1)]

USOnlyEventsByDay<-USOnlyGDelt[,(COUNT = .N),by=c("Date1", "EventRootCode", "EVENTDESCRIPTION")]
USOnlyEventsByCode<-USOnlyGDelt[,(COUNT = .N), by=c("EventRootCode", "EVENTDESCRIPTION")]
USOnlyEventsByCode<-USOnlyEventsByCode[order(-V1)]

USOnlyEventsByCode$USV1Perc<-USOnlyEventsByCode$V1/sum(USOnlyEventsByCode$V1)
EventsByCode$AllV1Perc<-EventsByCode$V1/sum(EventsByCode$V1)
PercentCombine<-merge(EventsByCode, USOnlyEventsByCode, by.x = "EVENTDESCRIPTION", by.y = "EVENTDESCRIPTION", suffixes = c(".All", ".US"))


ggplot(EventsByCode, aes(EVENTDESCRIPTION, V1))+geom_bar(stat="identity")
ggplot(EventsByDay, aes(x=Date1, y=V1))+geom_line(aes(colour=EVENTDESCRIPTION))
ggplot(USOnlyEventsByCode, aes(EVENTDESCRIPTION, V1))+geom_bar(stat="identity")
ggplot(USOnlyEventsByDay, aes(x=Date1, y=V1))+geom_line(aes(colour=EVENTDESCRIPTION))

