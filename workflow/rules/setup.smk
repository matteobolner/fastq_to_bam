rule bwa_index_ref:
    input:
        genome=config['ref_genome'],
    output:
        idx=multiext(
            config['ref_genome'],
            ".0123",
            ".amb",
            ".ann",
            ".bwt.2bit.64",
            ".pac",
        ),
    resources:
        mem_mb=25000,
    threads: 8
    log:
        "logs/bwa-mem2_index/indexing.log",
    shell:
        "bwa-mem2 index {input.genome} > {log}"
