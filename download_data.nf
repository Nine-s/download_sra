nextflow.enable.dsl = 2

process download_and_compress {
    label 'ALL'
    container 'ubuntu'
    
    input:
    val id

    output:
    file("${id}_*.fastq.gz")
    script:
    """
    apt update -y
    apt install ca-certificates -y
    fasterq-dump $id -O . --split-files --stdout | gzip > ${id}_output.fastq.gz
    """
}

workflow {
    file_ids = Channel.fromPath(params.identifiers)
                      .splitText()

    file_ids
        | map { id -> id.trim() } 
        | download_and_compress
}