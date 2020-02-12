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

data.extract.2 <- function(resource_id) {
  # Determine total row count
  url  <- "https://api.energidataservice.dk"
  path <- paste("datastore_search?resource_id=",
                resource_id,
                "&limit=5",
                sep = ''
  )
  this.content <- fromJSON(rawToChar(GET(url = url, path = path)$content))
  row.limit <- this.content$result$total
  # Extract the all observations to a data.frame
  path <- paste("datastore_search?resource_id=",
                resource_id,
                "&limit=",
                as.character(row.limit),
                sep = ''
  )
  data.extract.data.frame <- as.data.frame(fromJSON(rawToChar(GET(url = url, path = path)$content))$result$records)
  return(data.extract.data.frame)
}

data.extract.all <- function() {
  setwd("Z:/")
  dir.create(paste("Extracted_data_from_", Sys.Date(), sep = ''))
  setwd(paste("Z:","/Extracted_data_from_", Sys.Date(), sep = ''))
  total <- length(data.set.list)
  iter <- 0
  start <- Sys.time()
  for (i in 1:length(data.set.list)) {
    begin <- Sys.time()
    iter <- iter + 1
    #cat("Extracting:", as.character(data.set.list[i]), "\n")
    data.set <- data.extract.2(as.character(data.set.list[i]))
    save(data.set, file = paste(as.character(data.set.list[i]),".Rdata",sep=''))
    #cat("Done!","\n")
    end <- Sys.time()
    cat(iter, "of", total, "done | Iteration time:", difftime(end, begin, units = "secs"),
        "seconds | Total time spent:", difftime(end, start, units = "mins") ,"minutes", "\n")
  }
  finished <- Sys.time()
  cat("Total time spent:", difftime(finished, start, units = "mins"), "minutes", "\n")
}
data.extract.all()
