

rule analysis:
    input:
        data_dir = config['input_data_directory'],
    output:
        output_results_dir = directory(Path(output_directory, 'summary'))
    params:
        utils_script = Path(working_dir, 'scripts', 'utils.R')
    threads: 1
    conda: "../envs/r.yaml"
    script: "../scripts/analysis.R"


rule generate_report:
    input:
        input_dir = rules.analysis.output.output_results_dir
    output:
        report_html = os.path.join(output_directory, "report.html")
    params:
        output_file_name = "report.html",
        output_dir_path = os.path.join(output_directory),
        report_rmd = f"{working_dir}/scripts/generate_report.Rmd",
        report_rmd_final = f"{working_dir}/scripts/generate_report_final.Rmd",
    conda: "../envs/r.yaml"
    threads: 1
    script: "../scripts/generate_report.R"