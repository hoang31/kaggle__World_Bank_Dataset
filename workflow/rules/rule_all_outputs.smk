
## -------------------
## Rule All Outputs
## -------------------



def rule_all_outputs():
    
    output_list = list()

    output_results_dir = Path(output_directory, 'summary')
    output_list.append(output_results_dir)

    report_html = os.path.join(output_directory, "report.html")
    output_list.append(report_html)

    return(output_list)