#!/usr/bin/bash
mkdir -p bioproj
for prj in $(cat bioproject_result.long.txt);
do
if [ ! -f  bioproj/$prj.runinfo.csv ]; then
 curl -o bioproj/$prj.runinfo.csv "https://trace.ncbi.nlm.nih.gov/Traces/sra/sra.cgi?save=efetch&rettype=runinfo&db=sra&term=$prj"
 fi
 if [ ! -f bioproj/$prj.xml ]; then
   curl -o bioproj/$prj.xml "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=bioproject&id=$prj"
 sleep 2
 fi
done
