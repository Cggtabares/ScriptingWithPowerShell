#Parsing Excel
#As possible do not use PowerShell to parsing excel since the way to do it, it is through a community module
#Years before, to get the data from an excel file, we had to deal with com objects and more but now you can do two things:
#1. Save the excel as csv, this will be recommended whenever it is possible
#2. Use the community module ImportExcel, to install it, you can find it on PowerShell Gallery. to install it: Install-Module -Name ImportExcel

#Creating Excel Spreadhsheets
#
#Just like the csv command, we could pipe the resilts into the excel file
Get-Process | Export-Excel '.\Downloads\Powershell tests\Processes.csv'

#We can create many worksheet as we want
Get-Process | Export-Excel '.\Downloads\Powershell tests\Project 1 Build a computer inventory Report' -WorksheetName 'Worksheet2'
Get-Process | Export-Excel '.\Downloads\Powershell tests\Project 1 Build a computer inventory Report' -WorksheetName 'Worksheet3'

#Reading Excel Spreadsheets
#
#You can use the import-excel and it will return one or more PSCustomObject objects representing each row
#Import-Excel returns an object that uses the column names as properties

Import-Excel -Path '.\Downloads\Powershell tests\Processes.xlsx'

#If you want to retrieve a specific worksheet but you do not remember the name of those worksheet, you can use the following command to have the info of the excel
#this will show the info that we can use to pull data from all our worksheets

Get-ExcelSheetInfo -Path '.\Downloads\Powershell tests\Processes.xlsx'

#If we need to pull the data from all the worksheets

$excelSheets = Get-ExcelSheetInfo -Path '.\Downloads\Powershell tests\Processes.xlsx'
Foreach ($sheet in $excelSheets) {
        $workSheetName = $sheet.Name
        $sheetRows = Import-Excel -Path '.\Downloads\Powershell tests\Processes.xlsx' -WorkSheetName $workSheetName
        $sheetRows | Select-Object -Property *,@{'Name'='Worksheet';'Expression'={ $workSheetName } }
}

#Import-Excel does not return the reference to which row is the worksheet, in order to do that you use Select-Object
#Select-Object can be use as a simple string , specifying the property you want to return
#Select-object here it was used as a calculated property where you used the hashtable contraining the name of the property to return and an expression that runs when select-Object receives input. 
#The result of the expression will be the value of the new, calculated property

#Adding to Excel spreadsheets
#
#As any excel spreadsheet we will need to add some rows to the file, we can do this with the parameter -Append in the export-excel

#First, let's create a new worksheet of the proceesses that needs the timestamp everytime that the sommand is run and append the new results in the same worksheet 
#using the calculated property, i can create the timestamdp property (which it will be a new column for the file)

Get-Process | Select-Object -Property *,@{Name= 'Timestamp';Expression = { get-Date -Format 'MM--dd-yy hh:mm:ss' }} | Export-Excel '.\Downloads\Powershell tests\Processes.xlsx' -WorkSheetName 'ProcessesOverTime'

#Now we will use the command append, this is when you run this command after the first time

Get-Process | Select-Object -Property *,@{Name= 'Timestamp';Expression = { get-Date -Format 'MM--dd-yy hh:mm:ss' }} | Export-Excel '.\Downloads\Powershell tests\Processes.xlsx' -WorkSheetName 'ProcessesOverTime' -Append

