#Parsing JSON
#
#JSON is just plaintext, Powershell treats it as a string by default, where you can parse it or no parse it with Powershell
#
#To extract the string output -Raw text from JSON
Get-Content -Path .\employees.json -Raw
#
#You cannot use JSON as a string only, instead you need to convert from JSON to work from it. 
#
#ConvertFrom-Json can Parse the file and gives structure- Converting JSON to Objects
Get-Content -Path .\employees.json -Raw | ConvertFrom-Json
#
#You can see now that Employees is a property now.
#If you take a look at the employees property. you'll see that all the employee nodes have been parsed out, with each key representing a column header, and each value representing a row value
#
(Get-Content -Path .\employees.json -Raw | ConvertFrom-Json).employees
#
#The employees property is now an array of objects that you can query and manipulate just as any array
#
#PowerSHell can convert CSV file into a JSON file
#
#First we need to import the CSV, we need the delimiter to be
Import-CSV -Path .\Employees.csv -Delimiter "`t"
#
#
#Now we need to pipe the output to convertFrom-Json
Import-CSV -Path .\Employees.csv | ConvertTo-Json
#
#You can also add some parameters like compress, which minifiez the output by removing all the potentially unwanted line breaks
Import-CSV -Path .\Employees.csv -Delimiter "`t" | ConvertTo-Json -Compress
#
#
#The property will always be the node key, and the property value will always be the node value.
