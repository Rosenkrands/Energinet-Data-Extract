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

data.extract.all <- function() {
  data.list <- list()
  total <- length(data.set.list)
  iter <- 0
  cat("Extracting the first dataset...", "\n")
  start <- Sys.time()
  for (i in 1:length(data.set.list)) {
    begin <- Sys.time()
    iter <- iter + 1
    data.list[i] <- data.extract(as.character(data.set.list[i]))
    end <- Sys.time()
    cat(iter, "of", total, "done | Iteration time:", difftime(end, begin, units = "secs"),
        "seconds | Total time spent:", difftime(end, start, units = "secs") ,"seconds", "\n")
  }
  finished <- Sys.time()
  cat("Total time spent:", difftime(finished, start, units = "secs"), "seconds", "\n")
  return(data.list)
}
complete.list <- data.extract.all()
