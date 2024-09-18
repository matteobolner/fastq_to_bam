import pandas as pd


configfile: "config/config.yaml"


samples = pd.read_table(config["samples"]).set_index("sample", drop=False)


def get_all_fastqs_per_unit(wildcards):
    """Get preprocessed reads of given sample-unit."""
    sample = samples.loc[wildcards.sample]
    unit = samples.set_index("unit").loc[wildcards.unit]
    return [unit["fq1"], unit["fq2"]]


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


wildcard_constraints:
    sample="[^-]+",
