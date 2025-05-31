

## ----------------------------------------------------
## Script for ANALYSIS
## ----------------------------------------------------


library(tidyverse)
library(data.table)
source(snakemake@params[["utils_script"]])


## ----------------------------------------------------
## LOAD THE DATA
## ----------------------------------------------------

## output directory
output_directory <- snakemake@output[["output_results_dir"]]
dir.create(output_directory)

## get the files from the input directory
files <- list.files(path = snakemake@input[["data_dir"]], pattern = "*.csv", full.names = TRUE)

## read the file
data_dt <- fread(
    files[1],
    sep = ","
)


## ----------------------------------------------------
##  CODE
## ----------------------------------------------------

## summary stats
numerical_columns_summary <- get_summary_stats_numeric(data_dt)
categorical_columns_summary <- get_summary_stats_category(data_dt)

## get the number of rows containing the same country
data_dt[, n_occurence := .N, by = Country]


## ----------------------------------------------------
##  CODE - figures
## ----------------------------------------------------

## -----
## figure - boxplots of variables per countries
## -----

## format the data
data_dt_formatted <- melt(
    data_dt,
    id.vars = c("Country", "n_occurence"),
    measure.vars = c(
        "Year",
        "GDP (USD)",
        "Population",
        "Life Expectancy",
        "Unemployment Rate (%)",
        "CO2 Emissions (metric tons per capita)",
        "Access to Electricity (%)"
    )
)

fig_boxplot <- ggplot(
    data_dt_formatted,
    aes(
        x = Country,
        y = value,
        fill = Country
    )
) +
    geom_boxplot() +
    facet_wrap(
        vars(variable),
        scales = "free",
        ncol = 4
    ) +
    labs(
        x = "Country",
        y = "Values"
    ) +
    theme_bw(base_size = 14) +
    theme(
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        legend.position = "none"
    )

ggsave(
    filename = file.path(output_directory, "figure_boxplot_per_country.png"),
    plot = fig_boxplot,
    width = 17,
    height = 10
)


## -----
## figure - evolution of the variables per countries
## -----

## format the data
data_dt_formatted <- melt(
    data_dt,
    id.vars = c("Country", "n_occurence", "Year"),
    measure.vars = c(
        "GDP (USD)",
        "Population",
        "Life Expectancy",
        "Unemployment Rate (%)",
        "CO2 Emissions (metric tons per capita)",
        "Access to Electricity (%)"
    )
)
data_dt_formatted <- data_dt_formatted[order(Year)]
data_dt_formatted <- data_dt_formatted[order(Country)]
data_dt_formatted[, id := paste(Country, variable)]

fig_evolution <- ggplot(
    data_dt_formatted,
    aes(
        x = as.factor(Year),
        y = log10(value),
        color = variable,
        group = id
    )
) +
    geom_line(alpha = 0.7) +
    geom_point() +
    facet_wrap(
        vars(Country),
        scales = "free",
        ncol = 4
    ) +
    labs(
        x = "Year",
        y = "Values (Log10)"
    ) +
    theme_bw(base_size = 14) +
    theme(
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)
        #legend.position = "none"
    )

ggsave(
    filename = file.path(output_directory, "figure_evolution_trend_per_country.png"),
    plot = fig_evolution,
    width = 15,
    height = 15
)


## -----
## figure - evolution of the variables per countries
## -----

## format the data
data_dt_formatted <- melt(
    data_dt,
    id.vars = c("Country", "n_occurence", "Year"),
    measure.vars = c(
        "GDP (USD)",
        "Population",
        "Life Expectancy",
        "Unemployment Rate (%)",
        "CO2 Emissions (metric tons per capita)",
        "Access to Electricity (%)"
    )
)
data_dt_formatted <- data_dt_formatted[order(Year)]
data_dt_formatted <- data_dt_formatted[order(Country)]
data_dt_formatted[, id := paste(Country, variable)]

fig_evolution_per_country <- ggplot(
    data_dt_formatted,
    aes(
        x = as.factor(Year),
        y = log10(value),
        color = variable,
        group = id
    )
) +
    geom_line(alpha = 0.7) +
    geom_point() +
    facet_wrap(
        vars(Country),
        scales = "free",
        ncol = 4
    ) +
    labs(
        x = "Year",
        y = "Values (Log10)"
    ) +
    theme_bw(base_size = 14) +
    theme(
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)
        #legend.position = "none"
    )


ggsave(
    filename = file.path(output_directory, "figure_evolution_trend_per_country.png"),
    plot = fig_evolution,
    width = 15,
    height = 15
)




## -----
## figure - comparison of the evolution of the variables per countries
## -----

data_dt_formatted[, id := paste(Country, variable)]

fig_evolution <- ggplot(
    data_dt_formatted,
    aes(
        x = as.factor(Year),
        y = log10(value),
        color = Country,
        group = id
    )
) +
    geom_line() +
    facet_wrap(
        vars(variable),
        scales = "free",
        ncol = 1
    ) +
    labs(
        x = "Year",
        y = "Values (Log10)"
    ) +
    theme_bw(base_size = 14) +
    theme(
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5)
    )

ggsave(
    filename = file.path(output_directory, "figure_evolution_trend_per_variable.png"),
    plot = fig_evolution,
    width = 12,
    height = 20
)

## -----
## Correlation analysis between variables
## -----


variables_names <- colnames(data_dt)
variables_names <- variables_names[variables_names != "Country"]
variables_names <- variables_names[variables_names != "Year"]
variables_names <- variables_names[variables_names != "n_occurence"]

## variable combinations
var_combinations <- combn(variables_names, 2)
data_dt_formatted <- lapply(
    seq(1, ncol(var_combinations)),
    function(x){

        ## combination variable
        combi_var <- unlist(var_combinations[, x])
        var_to_extract <- c("Country", "Year", combi_var)

        ## create comparison name
        comparison_name <- paste(combi_var, collapse = " - ")

        ## get the data related to this combination
        data_dt_formatted <- data_dt[, var_to_extract, with = F]
        data_dt_formatted[, comparison_name := comparison_name]
        setnames(data_dt_formatted, old = combi_var, new = c("variable1", "variable2"))

        ## rename cols
        return(data_dt_formatted)
    }
)
data_dt_formatted <- rbindlist(data_dt_formatted)

fig_correlation <- ggplot(
    data_dt_formatted,
    aes(
        x = variable1,
        y = variable2,
        color = Country
    )
) +
    geom_point(size = 3) +
    facet_wrap(
        vars(comparison_name),
        scales = "free",
        ncol = 3
    ) +
    labs(
        x = "Variable 1",
        y = "Variable 2"
    ) +
    theme_bw(base_size = 10) +
    theme(
        axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5),
        legend.position = "top"
    )

ggsave(
    filename = file.path(output_directory, "figure_variable_correlation.png"),
    plot = fig_correlation,
    width = 12,
    height = 20
)









print("done")
Sys.sleep(10000)