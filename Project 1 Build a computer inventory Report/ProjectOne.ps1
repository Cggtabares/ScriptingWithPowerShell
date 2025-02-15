# Project 1

#Build a computer inventory Report

#You were hired as a Sysadmin into a new acquired company, you received a csv file with the folowing information:

#a CSV file that has all IP addresses of the subnet and what department it belongs.
#"192.168.0.1","IT"
#"192.168.0.2","Accounting"
#"192.168.0.3","HR"
#the subnet is 192.168.0.0/24

#You were given the task to check and create a new csv with the devices that the ip belongs, if it is connected (respond to the ping), dns name of that device, department where it belongs. This csv file will be presented to the management.

#Creating the script by the name of discovery_computers.ps1
#First, we need to read each row in the csv file, which it will be saved in a variable using import-csv

$rows = import-csv - path '.\Downloads\Powershell tests\Project 1 Build a computer inventory Report\IPAddresses.csv'

#Second, we need to ping to every row and get the hostname of the computer connected

#Test-connection it is used to ping and the -Quiet parameter it is used to return either treu or false as a value, also the -count parameter it is used to send just 1 packet for the ping

#-computerName was changed to the v7.1 to -TargetName, and it does do the same thing, you could type ip or name of the computer

Test-Connection -ComputerName $row[0].IPAddress -Count 1 -Quiet

#Resolve-DnsName it is used for query for names. -Name Specifies the name to be resolved, on this case the name will be the ipaddress of the csv
#Since Resolve.DNSName return multiple properties, we enclose the entire command and use the dot notation to return the Name Property.
#The -ErrorAction parameter in PowerShell determines how the shell should handle errors when they occur during command execution. Here are the main values you can use:
#-ErrorAction Stop              # Stops execution when an error occurs
#-ErrorAction Continue         # Displays error but continues execution (default)
#-ErrorAction SilentlyContinue # Suppresses error messages and continues
#-ErrorAction Ignore          # Suppresses error and continues (similar to SilentlyContinue)
#-ErrorAction Inquire         # Prompts user for action when error occurs

(Resolve-DnsName -Name $row[0].IPAddress -ErrorAction Stop).Name

#The previous code cannot be manually type per row, we can automate the action with a loop

foreach ($row in $rows){
        Test-Connection -ComputerName $row[0].IPAddress -Count 1 -Quiet
        (Resolve-DnsName -Name $row[0].IPAddress -ErrorAction Stop).Name
}

#The previous code just return bunch of true or false and hostnames, it does not group the info (IP Address, Depertment, IsOnline, Hostname, Error)
#also we need to save why we received an error when we run the code on those devices

#the complete code will be organized as following:
#Import the csv and save it in a variable
#loop that will read each row of the variable
#       handle any error with try
#           group in a hashmap all values of the properties that we need for the new csv files
#           Conditional to get the device is active or not and save it in a variable
#           Conditional to get the hostname
#       Closing the hanlde error with try
#       Show the error that could occur in try with catch
#       finally output the new hashmap variable as a PSCustomObject

#The code will be
$rows = Import-Csv -Path '.\Downloads\Powershell tests\Project 1 Build a computer inventory Report\IPAddresses.csv'
foreach($row in $rows){
    try{
        $output = @{
            IPAddresses = $row.IPAddress
            Department  = $row.Department
            IsOnline    = $false
            HostName    = $null
            Error       = $null
        }
        if (Test-Connection -ComputerName $row.IPAddress -Count 1 -Quiet) {
            $output.IsOnline = $true
        }
        if ($hostname = (Resolve-DnsName -Name $row.IPAddress -ErrorAction Stop).Name) {
            $output.Hostname = $hostname
        }
     } catch {
        $output.Error = $_.Exception.Message
     } finally {
        [pscustomobject]$output
     }
}

#Since the code it is save in the variable output, we can export it to csv
[psCustomObject]$output | Export-csv -Path '.\Downloads\Powershell tests\Project 1 Build a computer inventory Report\DeviceDiscovery.csv' -Append -NoTypeInformation
