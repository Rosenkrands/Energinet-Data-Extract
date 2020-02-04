library(httr)
library(jsonlite)
library(lubridate)

options(stringsAsFactors = F)

available.datasets.energinet <- function() {
  url  <- "https://api.energidataservice.dk"
  path <- "/package_list"
  raw.result <- GET(url = url, path = path)
  this.raw.content <- rawToChar(raw.result$content)
  this.content <- fromJSON(this.raw.content)
  as.data.frame(this.content)$result
}
data.set.list <- available.datasets.energinet()

data.extract <- function(resource_id) {
  # Determine total row count
  url  <- "https://api.energidataservice.dk"
  path <- paste("datastore_search?resource_id=",
                resource_id,
                "&limit=5",
                sep = ''
  )
  raw.result <- GET(url = url, path = path)
  this.raw.content <- rawToChar(raw.result$content)
  this.content <- fromJSON(this.raw.content)
  row.limit <- this.content$result$total
  # Extract the all observations to a data.frame
  path <- paste("datastore_search?resource_id=",
                  resource_id,
                  "&limit=",
                  as.character(row.limit),
                  sep = ''
                )
  raw.result <- GET(url = url, path = path)
  this.raw.content <- rawToChar(raw.result$content)
  this.content <- fromJSON(this.raw.content)
  data.extract.data.frame <- as.data.frame(this.content$result$records)
  return(data.extract.data.frame)
}