#!/usr/bin/env python3

import csv, os, re
import xml.etree.ElementTree as ET 

DEBUG=False
  
def parseXMLs(directory): 
    identifiers = []
    for xmlfile in os.listdir(directory):
        if xmlfile.endswith(".xml"):
            if DEBUG:
                print("processing",xmlfile)
            # create element tree object 
            tree = ET.parse(os.path.join(directory,xmlfile))
  
            # get root element 
            root = tree.getroot() 
  
            # create empty list for news items 
            
  
            # iterate news items 
            for item in root:
                
                # empty news dictionary 
                ids = {} 
                # iterate child elements of item 
                for child in item:                     
                    if child.tag == "Project":
                        for projchild in child:
                            for subproj in projchild:
                                #print(subproj,subproj.attrib)
                                if subproj.tag == "ArchiveID":
                                    ids['BioProject'] = subproj.get('accession')
                                    ids['BioProjectId'] = subproj.get('id')
                                elif subproj.tag == "CenterID":
                                    #if subproj.get('center') == "DOE Joint Institute":
                                    ids['JGI_Project_Id'] = subproj.get('id')
                                    ids['Provider'] = subproj.get('center')
                                elif subproj.tag == 'Title':
                                    #print(subproj.text)                                    
                                    ids['Name'] = str(subproj.text.encode('utf-8').strip().decode())
                                    #ids['Name'] = subproj.text
                                elif subproj.tag == 'LocusTagPrefix':
                                    ids['BioSample'] = subproj.get('biosample_id')
            if ('Provider' in ids and 
                not re.search('FGSC8790',ids['Name']) and 
                ids['JGI_Project_Id'] != '1069856' and # skip John Taylor cross strains
                ids['JGI_Project_Id'] != '1109079'): # skip Pierre Clade B Ncrassa strain

                patterns = [r'Neurospora crassa strain:',r'Neurospora crassa\s+',
                            r'\s*(Genome sequencing|Resequencing)']
                Strain = ids['Name']
                for pattern in patterns:
                    Strain = re.sub(pattern,'',Strain,flags=re.IGNORECASE)
                if re.search(r'^\d+',Strain):
                    Strain = 'FGSC %s'%(Strain)

                ids['Strain'] = re.sub(r'\s+','_',Strain)
                with open(os.path.join(directory,ids['BioProject']+".runinfo.csv"),"r") as sra:
                    parsecsv = csv.DictReader(sra,delimiter=",")
                    sra_runs = []
                    for row in parsecsv:                        
                        sra_runs.append(row['Run'])
                    ids['SRA_Run'] = ";".join(sra_runs)
                identifiers.append(ids)
                
    return identifiers
  

def add_SRA(idlist):
    for id in idlist:
        print(id)
        
  
def savetoCSV(ids, filename): 
  
    # specifying the fields for csv file 
    fields = ['BioProject','BioProjectId','JGI_Project_Id',
              'BioSample','Strain','Name','SRA_Run','Provider']
  
    # writing to csv file 
    with open(filename, 'w',encoding='utf=8') as csvfile: 
  
        # creating a csv dict writer object 
        writer = csv.DictWriter(csvfile, fieldnames = fields)
  
        # writing headers (field names) 
        writer.writeheader() 
  
        # writing data rows 
        writer.writerows(ids) 
  
      
def main():   
    # parse xml file 
    ids = parseXMLs('bioproj')
    # store news items in a csv file 
    savetoCSV(ids, 'bioprojects.csv')
      
      
if __name__ == "__main__": 
  
    # calling main function 
    main() 
