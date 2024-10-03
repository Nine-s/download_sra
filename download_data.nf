nextflow.enable.dsl = 2

process download_and_compress {
    label 'ALL'
    container 'ubuntu'
    
    input:
    path identifiers_file 

    output:
    file("${id}_*.fastq.gz")

    script:
    """
    apt update -y
    apt install ca-certificates -y
    
    while IFS= read -r id; do

        if [ -z "\$id" ]; then
            continue
        fi

        echo "Processing identifier: \$id"
        fasterq-dump \$id -O . --split-files --stdout | gzip > \${id}_output.fastq.gz

        if [ \$? -eq 0 ]; then
            echo "Download and compression completed for \$id"
        else
            echo "Error occurred with \$id"
        fi

    done < ${identifiers_file}
    """
}

workflow {
    download_and_compress(params.identifiers)
}