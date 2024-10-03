nextflow.enable.dsl = 2

process download_and_compress {
    label 'ALL'
    container 'ubuntu'
    
    input:
    path identifiers_file 

    output:
    file("_*.fastq.gz")

    script:
    """
    apt update -y
    apt install ca-certificates -y

    useradd -ms /bin/bash myusertest
    cp ${identifiers_file} /home/myusertest/
    su - myusertest -c "
        # Set up directories and permissions
        mkdir -p /home/myusertest/sra_cache
        chmod 777 /home/myusertest/sra_cache
        export VDB_CONFIG=/home/myusertest/.ncbi

        # Configure SRA Toolkit
        vdb-config --prefetch-to-cwd
        vdb-config --set \"/repository/user/main/public/root=/home/myusertest/sra_cache\"
        vdb-config --list

        # Process the identifiers file
        while IFS= read -r id; do
            echo "Processing identifier: \$id"
            # Download and compress the file directly to the original working directory
            fasterq-dump \$id --split-files --stdout | gzip > /workspace/\${id}_output.fastq.gz

            # Check for success
            if [ \$? -eq 0 ]; then
                echo "Download and compression completed for \$id"
            else
                echo "Error occurred with \$id"
            fi
        done < ${identifiers_file}  # Use the identifiers file path correctly
    "
    """
}

workflow {
    download_and_compress(params.identifiers)
}