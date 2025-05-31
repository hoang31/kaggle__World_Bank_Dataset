
## ----------------------------------------------------
## ULTILS
## ----------------------------------------------------


library(tidyverse)
library(data.table)


## ----------------------------------------------------
## FUNCTIONS
## ----------------------------------------------------


## get_summary_stats
get_summary_stats_numeric <- function(data_dt) {

    ## get the numeric columns
    columns_summary <- data_dt[ , .SD, .SDcols = is.numeric]
    
    ## load the data
    columns_summary <- as.data.table(summary(columns_summary))
    setnames(columns_summary, "V2", "column_names")
    columns_summary <- columns_summary[!(is.na(N)), ]
    
    ## get the metrics name
    columns_summary[, metrics_name := sapply(N, function(x) {
        splitted <- strsplit(x, ":")[[1]][1]
        return(splitted)
    })]
    columns_summary[, metrics_name := str_remove_all(metrics_name, " |[.]")]

    ## get the metrics value
    columns_summary[, metrics_value := sapply(N, function(x) {
        splitted <- strsplit(x, ":")[[1]][2]
        return(splitted)
    })]

    columns_summary[, V1 := NULL]
    columns_summary[, N := NULL]

    ## format the data
    columns_summary <- dcast(
        columns_summary,
        column_names ~ metrics_name,
        value.var = "metrics_value"
    )

    ## order the cols
    columns_summary <- columns_summary[, c("column_names", "Min", "1stQu", "Median", "3rdQu", "Max", "Mean"), with = F]

    return(columns_summary)
}




## get_summary_stats
get_summary_stats_category <- function(data_dt) {

    ## get the numeric columns
    columns_summary <- data_dt[ , .SD, .SDcols = is.character]

    ## get columns names
    col_names <- colnames(columns_summary)

    ## for each column, count the number of unique values
    col_data <- lapply(col_names, function(x) {
        values <- unique(unlist(columns_summary[, x, with = F]))

        output <- data.table(
            column_names = x,
            unique_values = length(values),
            values = paste(sort(values), collapse = "/")
        )
    })
    columns_summary <- rbindlist(col_data)
    return(columns_summary)
}