

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


#rule generate_report:
#    input:
#        input_dir = rules.analysis
#    output:
#        report_html = os.path.join(_RESULTS_DIR, "report", "{sample}_report.html")
#    params:
#        output_file_name = "{sample}_report.html",
#        output_dir_path = os.path.join(_RESULTS_DIR, "report"),
#        report_rmd = f"{working_dir}/scripts/generate_report.Rmd",
#        report_rmd_final = f"{working_dir}/scripts/generate_report_{{sample}}.Rmd",
#        enable_kraken2_analysis = enable_kraken2_analysis,
#        enable_blast_analysis = enable_blast_analysis,
#        enable_kma_amr_identification = enable_kma_amr_identification,
#        process_negative_sample = process_negative_sample,
#        enable_kraken2_analysis_cons_seq = enable_kraken2_analysis_cons_seq

#    conda: "../envs/r.yaml"
#    threads: 1
#    script: "../scripts/generate_report.R"