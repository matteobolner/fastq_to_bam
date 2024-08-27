import pandas as pd


configfile: "config/config.yaml"


samples = pd.read_table(config["samples"]).set_index("sample", drop=False)


def get_all_fastqs_for_sample(wildcards):
    sample = samples[samples["sample"] == wildcards.sample]
    fastqs = []
    for i in sample["unit"]:
        fastqs += [f"{i}_1.fq.gz", f"{i}_2.fq.gz"]
    fastq_paths = [f"{config['samples_path']}/{wildcards.sample}/{i}" for i in fastqs]
    return fastq_paths


def get_all_fastqs_per_run(wildcards):
    """Get preprocessed reads of given sample-unit."""
    return expand(
        f"{config['samples_path']}/{wildcards.sample}/{wildcards.unit}_{{group}}.fq.gz",
        group=[1, 2],
        **wildcards,
    )


def get_sample_bams(wildcards):
    """Get all aligned reads of given sample."""
    return expand(
        f"{config['bam_folder']}/{{sample}}-{{unit}}.bam",
        sample=wildcards.sample,
        unit=samples.loc[wildcards.sample].unit,
    )


def get_number_of_bams_per_sample(wildcards):
    """Get number of bams per given sample."""
    sample = wildcards.sample
    unit = samples.loc[wildcards.sample].unit
    return len(unit)
