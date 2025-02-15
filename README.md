# ScriptingWithPowerShell
Study of the book PowerShell for SysAdmins that results in some interesting scripts to use

# PowerShell-SysAdmin-Scripts

This repository contains PowerShell scripts developed while working through "PowerShell for Sysadmins" by Adam Bertram (ISBN-13: 
9781593279189). These scripts cover various system administration tasks and are intended for educational purposes.

## Book Information

Scripts based on "PowerShell for Sysadmins" by Adam Bertram.

##Repository Information

All Repo is a personal interpretation of the Book's Chapters, Which are the Following:

*    Part 1: Fundamentals: Basic PowerShell Concepts, Combining Commands, Control Flow, Error Handling, Writing Functions, Exploring Modules, Running Scripts Remotely, Testing With PESTER
*    Part 2: Automating Day-to-Day tasks: Parsing Structured Data (CSV, JSON, and Excel), Automating Active Directory, Working With Azure, Working With AWS, Creating a Server Inventory Script
*    Part 3: Building your Own Module: Provisioning a Virtual Environment, Installing an Operating System, Deploying Active Directory, Creating and COnfiguring a SQL Server, Refactoring your Code, Creating and configuring an IIS Web Server
      

## Repository Organization

Scripts are organized by Project and utility.

*   `Project_number/`: Scripts related to Projects inside the Book, inside the folder, the files are organized as follows:
    *    `ProjectNumber.ps1`: Scripts will all explanation what does the code do
    *    `*.ps1`: Script only to be executed
    *    `*.csv`: File that has the data example for some Scripts or results from the Script      
*   `*.csv,.Json,.xslx`: File that has the data example for some Scripts

## How to Use

1.  Navigate to the script's directory in PowerShell.
2.  Execute the script: `.\ScriptName.ps1`
3.  Use `Get-Help .\ScriptName.ps1 -Full` for parameter information.

## Examples

*   Get user info: `.\New-Employee.ps1 -FirstName 'johndoe' -LastName 'Doe' -Department 'IT' -EmployeeNumber 'EmployeeNumber`

## Disclaimer

These scripts are for educational purposes only. Use them at your own risk. No warranty is provided.
