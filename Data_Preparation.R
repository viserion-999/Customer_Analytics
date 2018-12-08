
#Check if package exists, if not install the package & load the package.

if (!require("openxlsx")) install.packages("openxlsx")
library("openxlsx")

#Read the customer satisfaction data

if (!exists('cs_data'))
{
  cs_data <- read.xlsx("satisfaction.xlsx", sheet = 1, colNames = TRUE,rowNames = FALSE, skipEmptyRows = TRUE,
                       skipEmptyCols = TRUE, na.strings = NA,fillMergedCells = FALSE)
  
  ##Checking the first few rows of the data.
  head(cs_data)
  colnames(cs_data)
  ##summary 
  str(cs_data)
  
}
#Split age variable into categories
#cs_data$Age <- seq(min(cs_data$Age), max(cs_data$Age), len=10)
#Converting scales to factor variables.
cols_to_factor1 <- c("satisfaction_v2", "Gender", "Customer.Type", "Type.of.Travel","Class")
cs_data$satisfaction_v2 <- as.factor(cs_data$satisfaction_v2)
cs_data[cols_to_factor1] <- lapply(cs_data[cols_to_factor1], as.factor) 
cols_to_factor2 <- c("Seat.comfort","Departure/Arrival.time.convenient","Food.and.drink","Inflight.wifi.service","Inflight.entertainment","Online.support","Ease.of.Online.booking","Gate.location","On-board.service","Leg.room.service","Baggage.handling","Checkin.service","Cleanliness","Online.boarding")
cs_data[cols_to_factor2] <- lapply(cs_data[cols_to_factor2], as.factor)

#Summary after factoring the variables.
str(cs_data)

