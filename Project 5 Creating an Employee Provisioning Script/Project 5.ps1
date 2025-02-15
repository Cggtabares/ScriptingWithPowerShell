#Project 5
#
#Creating am Employee Provisioning Script
#
#A new employee has been hired and needs a AD user, Computer account, and adding it to the specific groups
#You as a System Administrator can create an user through clics, however, when you have more than 2 users to create, it will take a very long time to complete the tasks
#For this, it is better to user a script
#
#
#First, before start any prject, it is important to figure out what the script will do and write down an informal definition. For this Script, 
#you need to create the AD user, which will:
#-Dynamically create a username for user based on the first name and last name
#-Create and assign the user a random password
#-Force the user to change their password at logon
#-Set the department attribute based on the department given (Department and OU = group )
#-Assign the user an internal employee number
#
#To crerate the script, we would need a dynamic way to reuse the script.
#The first line is to check if the machine has the Active Directory module installes
#The second block has the parameters to be introduced when creating the user
#The third is a try catch block in case an error occured
#

#requires -Module ActiveDirectory

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$FirstName,
    
    [Parameter(Mandatory)]
    [string]$LastName,
    
    [Parameter(Mandatory)]
    [string]$Department,
    
    [Parameter(Mandatory)]
    [int]$EmployeeNumber
)

try {    }
    catch {
        Write-Error -Message $_.Exception.Message
    }

#Now we created the base, now we fill try block
#To create the AD user, we would need it to created dynamically from the name and last name
#Some companies prefer firstname and lastname, others first initial of the name and lastname.
#We will take the first initial of the firstname and lastname, and if it is already taking the username, 
#it will iterate taking the second leter of the firstname until the username is unique
#
#
#First, handle the base first. You'll use the built-in Substring method on every string object to get the first initial.
#You'll then concatenate the last name to the first initial. You'll do this by using string formatting, which allows you to define placeholders
#for multiple expressions in a string and replace the placeholders with value at runtime
#
$userName = '{0}{1}' -f $FistName.Substring(0, 1), $LastName
#
#Check if the username exist in the AD
Get-ADUser -Filter "samAccountName -eq '$userName'"
#
#If the command retunrs anything, the username is taken, and you need to try the next username
#We need to create dynamically the creation of the username but we cannot pass the firtname, so we can use a while Loop to prevent this
#The condition looks like this:
(Get-ADUser -Filter "samAccountName -eq '$userName'") -and ($userName -notlike "$Firstname*")
#
#Fill the while block
$i = 2
while ((Get-ADUser -Filter "samAccountName -eq '$userName'") -and ($userName -notlike "$Firstname*")) {
    Write-Warning -Message "The username [$($userName)] already exists. Trying another... "
    $userName = '{0}{1}' -f $FistName.Substring(0, $i), $LastName
    Start-Sleep -Seconds 1
    $i++
}
#
#
#Now we need to check if the organizational unit and group exists, where you are adding the user
if (-not ($ou = Get-ADOrganizationalUnit -Filter "Name -eq '$Department'")) {
    throw "The Active Directory OU for department [$($Department)] could not be found."
} elseif (-not (Get-ADGroup -Filter "Name -eq '$Department'")) {
    throw "The group [$($Department)] does not exist."
}

#
#
#Once you complete all the checks, you need to create the user account password, generate randomly
#An easy way to generate a secure password is to use the GeneratePassword static method on the System.web.security.Membership object
Add-Type -AssemblyName 'System.Web'
$password = [System.Web.Security.membership]::GeneratePassword((Get-Random Minimum 20 -Maximum 32),3)
$secPW = ConverTo-SecureString -String $password -AsPlainText -Force
#
#We chose to have a minimum of 20 characters but we can find the AD's minimum required password by running 
Get-ADDefaultDomain PasswordPolicy | Select-Object -expand minPasswordLength
#
#Now we have secure password, we have all parameters values needed to create the user according to the requirements
#
$NewUserParams = @{
    GivenName                 = $FirstName
    EmployeeNumber            = $EmployeeNumber
    Surname                   = $LasttName
    Name                      = $UserName
    AccountPassword           = $secPW
    ChangePasswordAtLogon     = $true
    Enabled                   = $true
    Department                = $Department
    Path                      = $ou.DistinguishedName
    Confirm                   = $false
}
New-ADUser @newUserParams

#After created the user, we just have to add to the department and group
#
Add-GroupMember -Identity $Department -Members $userName

