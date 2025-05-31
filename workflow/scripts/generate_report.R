

## copy the generate_report.Rmd with sample name - avoid overlapping outputs
rmd_script_initial <- snakemake@params[["report_rmd"]]
rmd_script_final <- snakemake@params[["report_rmd_final"]]
file.copy(rmd_script_initial, rmd_script_final, overwrite = T)

## inputs files
input_dir <- snakemake@input[["input_dir"]]
input_dir <- normalizePath(input_dir)
print(input_dir)

rmarkdown::render(
    input = rmd_script_final,
    output_file = snakemake@params[["output_file_name"]],
    output_dir = snakemake@params[["output_dir_path"]],
    params = list(
        input_dir = input_dir,
        output_file = snakemake@output[["report_html"]]
    ),
    knit_meta = F
)

# Read the HTML content from the rendered file
html_content <- readLines(snakemake@output[["report_html"]])

# Remove lines containing metadata (lines starting with "---")
lines_to_remove_regex <- "Project Report|input_dir|output_file"
html_content <- html_content[!grepl(lines_to_remove_regex, html_content)]

# Write the cleaned HTML content back to the file
writeLines(html_content, snakemake@output[["report_html"]])

## remove the final rmd script
file.remove(rmd_script_final) 
