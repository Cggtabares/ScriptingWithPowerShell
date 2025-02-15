#Parsing Structure Data
#Parsing CSV

#Reading CSV Files with Get-Content
Get-Content -Path '.\Downloads\Powershell tests\Employees.csv' -Raw

#Get-Content does not understand the a CSV file structure, get-member (the methods and properties related to this object)
Get-Content '.\Downloads\Powershell tests\Employees.csv' -Raw | Get-Member

#using Import-csv is different than Get-Content since the first one, process the data as you prefer, examples:
#This import it will show every row as a group of properties
Import-Csv -Path '.\Downloads\Powershell tests\Employees.csv'

#This import will show the csv as table
Import-Csv -Path '.\Downloads\Powershell tests\Employees.csv' | Format-Table

#Get-member as import csv, it will show as a PSCustomObject. This is important since Import-csv convert the csv into a object that Powershell can work with it
Import-Csv -Path '.\Downloads\Powershell tests\Employees.csv' | Get-member
d
#Get first object of the csv and save into a varibale
$firstCSVRow = Import-Csv -Path '.\Downloads\Powershell tests\Employees.csv' | Select-Object -First 1

#Show which first name is in the first row saved in the variable
#$firstCSVRow | Select-Object -ExpandProperty "First Name"

#The first thing that Import-csv do after read is to take the first row as the header row and take the common delimiter as a separation between columns but does not understand the content, just the structure
#In IMport-csv, Each object has properties that correspomd to the headers in the heaqder row, and if you want the data for that header's column, all you have to do is access that property
#also Import-csv take the content of the file and put into an array of PSCustomObjects

Import-Csv -Path '.\Downloads\Powershell tests\Employees.csv' | Where-Object { $_.'Last Name' -eq 'Bertram'} | Format-Table

Import-Csv -Path '.\Downloads\Powershell tests\Employees.csv' | Where-Object { $_.Department -eq 'Executive Office'} | Format-Table

#commas are the delimiter that import-csv natively understands
#replacing the commas for a tabs
(Get-Content '.\Downloads\Powershell tests\Employees.csv' -Raw).replace("'t" , ' ') | Set-Content '.\Downloads\Powershell tests\Employees.csv'

#Set-Content will be used to save the result of the command and show the csv raw again but with the space as a delimiter
Get-Content '.\Downloads\Powershell tests\Employees.csv' -Raw

#Defining Your own header
#-delimiter <value> - using the custom delimiter
#-Header <values> - type the headers name you want
Import-csv -Path '.\Downloads\Powershell tests\Employees.csv' -Delimiter " " -Header 'Employee FName', 'Employee LName'. 'Dept', 'Manager'

#Create CSV Files with export-csv
#You can use out-file for the results it will be a file with non-structure as csv file,if you export-csv it will export the information as the csv files

#For example: Create a CSV from the get process
#-notypeInformation - Removes the #TYPE information header from the output.
Get-Process | Select-Object -Property Name,Company, Description | Export-csv -Path '.\Downloads\Powershell tests\Processes.csv' -NoTypeInformation

Import-csv -Path '.\Downloads\Powershell tests\Processes.csv' | Format-Table