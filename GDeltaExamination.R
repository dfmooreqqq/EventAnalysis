# Environment Setup -------------------------------------------------------
## Environment setup
# Load packages.
packages <- c("gdata", "ggplot2", "plyr", "reshape2", "tm", "dplyr", "Matrix", "GDELTtools", "data.table", "date", "lubridate")
packages <- lapply(packages, FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
        install.packages(x)
        library(x, character.only = TRUE)
    }
})


# Load Data ---------------------------------------------------------------
endstr = format(Sys.Date()-1, format="%m/%d/%y")
startstr = format(Sys.Date()-8, format="%m/%d/%y")

GDeltLastweek<-data.table(GetGDELT(start.date = startstr, 
         end.date = endstr, 
         data.url.root = "http://data.gdeltproject.org/events/",
         verbose = TRUE))

GDeltLastweek$Date1<-parse_date_time(as.character(GDeltLastweek$SQLDATE), order="ymd")

# Format Tables------------------------------------------------------------
EventsByDay<-GDeltLastweek[,(COUNT = .N),by=c("Date1", "EventCode")]
EventsByCode<-GDeltLastweek[,(COUNT = .N), by=c("EventCode")]
ggplot(EventsByDay, aes(Date1, V1))+geom_bar(stat="identity")
