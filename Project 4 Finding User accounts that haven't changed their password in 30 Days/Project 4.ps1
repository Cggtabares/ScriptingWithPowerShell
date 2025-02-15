#Project 4
#
#Finding User accounts that haven't changed their password in 30 Days
#
#The company will implement a new password policy but they need to know first how many users haven't changed their password in the last 30 days
#
#We can use Search-ADAccount and filter with the parameters but there is not a parameter that do that
#We would need to build our custom parameters 
#
#also we would need to filter the users that are enabled
#
#Filter enabled users
Get-ADUser -Filter "Enabled -eq 'True'"
#
#Now the step is to access when the password is set
#Get-ADUser does not return woth all properties, we have to select the parameter passwordlastSet
#There are some users thaqt do not have a lastset password since they have never set their own password
Get-ADUser -Filter * -Properties passwordlastset | select name.passwordlastset
#
#Now that you have the propertie, we need to create a filter for the date
#
#To find a date difference, you need two dates: the oldest possible date (30 days ago) and the newest possible date (today)
#To find the date today
$today = Get-Date
#Now we can create a variable that can save the date today minus 30 days, which we can use the addDaysmethod
$30DaysAgo = $today.AddDays(-30)
#
#Join the filter with Get-ADUSer
Get-ADUser -Filter "passwordlastset -lt '$30DaysAgo'"
#
#Finding enabled user accounts that haven't changed their password in 30 days
$today = Get-Date
$30DaysAgo = $today.AddDays(-30)
Get-ADUser -Filter "Enabled -eq 'True' -and passwordlastset -lt '$30DaysAgo'"