#!/bin/bash

# Command: ./workflow-realigner.sh project_name my_gs read_type reads realign(optional)

export location="$PWD" 			#Save path to bowtie2-build and bowtie2 in variable BT2
project_name=$1
my_gs=$2
my_sample_mode=$3
my_rd=$4
realign=$5

#Directories management
f0=user_data
f1=projects/$project_name/1_intermediate_files
f2=projects/$project_name/2_logs
f3=projects/$project_name/3_workflow_output
mkdir ./projects/$project_name
mkdir $f1
mkdir $f2
mkdir $f3

#temp
my_rf=SRR1664664_1.fastq
my_rr=SRR1664664_2.fastq

#Realignments
realignments=""
if [ -v "$realign" ] 
then
	realignments="-m -F"
fi

#Run bowtie2-build on genome sequence 
$location/bowtie2/bowtie2-build $f0/$my_gs $f1/genome_index 1> $f2/bowtie2-build_std1.txt 2> $f2/bowtie2-build_std2.txt

#Run botwie2 unpaired
if [ $my_sample_mode == se ] 
then
	$location/bowtie2/bowtie2 --very-sensitive --mp 6,2 -x $f1/genome_index -U $f0/$my_rd -S $f1/alignment1.sam 2> $f2/bowtie2_problem-sample_std2.txt
fi

#Run bowtie2 paired
if [ $my_sample_mode == pe ] 
then
	$location/bowtie2/bowtie2 --very-sensitive  --mp 6,2 -X 1000  -x $f1/genome_index -1 $f0/$my_rf -2 $f0/$my_rr -S $f1/alignment1.sam 2> $f2/bowtie2_problem-sample_std2.txt
fi

#SAM to BAM
$location/samtools1/samtools sort $f1/alignment1.sam > $f1/alignment1.bam 2> $f2/sam-to-bam_problem-sample_std2.txt
#rm -rf ./user_projects/$project_name/1_intermediate_files/alignment1.sam

#Variant calling
$location/samtools1/samtools mpileup -B -t DP,ADF,ADR $realignments  -uf $f0/$my_gs $f1/alignment1.bam 2> $f2/mpileup_problem-sample_std.txt | $location/bcftools-1.3.1/bcftools call -mv -Ov > $f1/raw_variants.vcf 2> $f2/call_problem-sample_std.txt

#Groom vcf
python2 $location/vcf-groomer.py -a $f1/raw_variants.vcf -b $f1/F2_raw.va 


#Intermediate files cleanup
rm -f $f1/*.sam
rm -f $f1/*.vcf


exit

#Intermediate files cleanup
rm -f $f1/*.sam
rm -f $f1/*.vcf
rm -f $f1/*.bam
rm -f $f1/*.bai
if [ -d "$f1/sim_data" ]; then rm -Rf $f1/sim_data/; fi


echo $exit_code
