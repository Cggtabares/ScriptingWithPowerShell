#Project 2
#
#Creating a Windows Service Monitoring Tool
#
#You'd been hired to buila a process track Windows services states over time and record them to an Excel worksheet.Then you'll build a report
#showing when various services have changed state - basically, you're making a lo-fi monitoring too
#
#First: Pull all Windows services, returning only their name and state.
Get-Service | Select-Object -Property Name,Status
#Second: Get a timestamp on each row in the excel worksheet
Get-Service | Select-Object -Property Name,Status,@{Name= 'Timestamp';Expression = { Get-Date -Format 'MM-dd-yy hh:mm:ss' }} | Expot-Excel .\ServicesStates.xlsx - WorksheetName "Services"
#
#You can play with this exercise: stopping some services and run it again, and run the following script to append the information to the same excel
Get-Service | Select-Object -Property Name,Status,@{Name= 'Timestamp';Expression = { Get-Date -Format 'MM-dd-yy hh:mm:ss' }} | Expot-Excel .\ServicesStates.xlsx - WorksheetName "Services" -Append
#
#Now, we can summarize the data into the excel but into a PivotTable, which it will help you to grouping one or more properties together and then performing ac action on those properties corresponding values (counting,adding, and so on).
#Using a pivot tables, you can easily spot which services changed states and when they did so.
#
#You'll use IncludePivotTable,PivotRows, PivotColumns, and PivotDatapara meters to create a summary pivot table
Import-excel .\serviceStates.xlsx -worksheet "services" | Export-Excel -Path .\ServicesStates.xlsx -Show -IncludePibotTable -PivotRows Name,TimeStamp -PivotData @{TimeStamp = 'count'} -PivotColumn Status

