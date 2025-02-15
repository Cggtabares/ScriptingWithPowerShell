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
        [psCustomObject]$output | Export-csv -Path '.\Downloads\Powershell tests\Project 1 Build a computer inventory Report\DeviceDiscovery.csv' -Append -NoTypeInformation
     }
}