
## -------------------
## Rule All Outputs
## -------------------



def rule_all_outputs():
    
    output_list = list()

    output_results_dir = Path(output_directory, 'summary')
    output_list.append(output_results_dir)
    
    return(output_list)