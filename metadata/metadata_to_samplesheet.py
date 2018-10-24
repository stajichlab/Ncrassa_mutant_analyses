#!/usr/bin/env python3
import csv, os, re, sys
fastqdir = '../fastq'
file="bioprojects.csv"
outfile="samples.csv"
if len( sys.argv) > 1:
    file = sys.argv[1]

print(file)

with open(file,"r") as bioproj, open(outfile,"w",newline="") as samples:
    reader = csv.DictReader(bioproj)
    
    fieldnames=['SRA_Run','Strain', 'BioSample','BioProject',
                'Read_1','Read_2','Paired']
    writer = csv.DictWriter(samples, fieldnames=fieldnames,delimiter=",")

    writer.writeheader()
    for row in reader:
        for ignorekey in ['Provider','JGI_Project_Id',
                          'BioProjectId','Name']:                
            del row[ignorekey]

        for sra in row['SRA_Run'].split(";"):
            newrow = dict(row)
            newrow['SRA_Run'] = sra
        
            fwdread = "%s_%d.fastq.gz"%(sra,1)
            revread = "%s_%d.fastq.gz"%(sra,2)
            newrow['Paired'] = "Y"
            if os.path.isfile(os.path.join(fastqdir,fwdread)):
                newrow['Read_1'] = fwdread
            else:
                newrow['Read_1'] = 'NONE'
                newrow['Paired'] = "N"
                

            if os.path.isfile(os.path.join(fastqdir,revread)):
                newrow['Read_2'] = revread
            else:
                newrow['Read_2'] = 'NONE'
                newrow['Paired'] = "N"

            writer.writerow(newrow)
