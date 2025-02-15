#Project 3
#
#Querying and Parsing a REST API
#
#One of the important activities for a Sysadmin is to Parse information, this case we will query a REST API (with no authentication) and we will Parse the results
#
#for the URI you can use any API, I will use https://rickandmortyapi.com/api
#When you request information to the API, it will respond in JSON form
#To query the URI API, you'll use PowerShell's Invoke-WebRequest cmdlet
Invoke-WebRequest -URI 'https://rickandmortyapi.com/api'
#
#
#To parse the results e would need to svae it in a variable
$result = Invoke-WebRequest -URI 'https://rickandmortyapi.com/api'
#
#To show only the content
$result.Content
#
#In windows Powershell, invoke-webrequest relies on Internet Explorer. If you do not have Internet Explorer on your computer, you may have to use the -UseBasicParsing parameter to remove the dependency.
#Advanced parsing breaks down the resulting HTML output a bit more but it's not needed in all cases.
#
#You can convet it with you commands
$result = Invoke-WebRequest -URI 'https://rickandmortyapi.com/api'
$contentObject = $result.Content | ConvertFrom-Json
$contentObject
#
#
#
#You can convert the result with one command: Invoke-RestMethod
#invoke-RestMethod is similar in functionality to Invoke-WebRequest, you can use the first since it does not require authentication to return values
#
#
Invoke-RestMethod -URI "https://rickandmortyapi.com/api/character"
#
#As you see here, this command returne an HTTP status code and the response from the API in the result property.
#the result was already converted to JSON, you just have to see the result(s) property
#
(Invoke-RestMethod -URI "https://rickandmortyapi.com/api/character").results

