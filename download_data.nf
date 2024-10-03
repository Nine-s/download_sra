nextflow.enable.dsl = 2

process download_and_compress {
    label 'ALL'
    container 'ubuntu'
    
    input:
    val id from file(params.identifiers)

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
    download_and_compress
}