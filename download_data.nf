nextflow.enable.dsl = 2

process download_and_compress {
    label 'ALL'
    container 'ubuntu'
    
    input:
    val id

    output:
    file("${id}_*.fastq.gz") into compressed_files

    script:
    """
    apt update
    apt install ca-certificates
    fasterq-dump $id -O . --split-files --stdout | gzip > ${id}_output.fastq.gz
    """
}

workflow {
    file_ids = Channel.fromPath(params.identifiers)
                      .splitText()

    file_ids
        | map { id -> id.trim() }  // Clean up any surrounding whitespace
        | download_and_compress
}