#region One-time only

## Authenticate interactively. Use -SubscriptionId if you have multiple subscriptions
Add-AzAccount

## Create the application
##identifierURIS, it needs to be the primary domain and /<name for the app>
$myApp = New-AzADApplication -DisplayName AppForServicePrincipal -IdentifierUris 'http://primaryDomain/AppName' 

## Extract the AppId
$appId = $myApp.AppId

## Create the service principal and capture the output
$sp = New-AzADServicePrincipal -ApplicationId $appId -SkipAssignment

## Extract the client ID and client secret
$clientId = $sp.KeyId
$clientSecret = $sp.SecretText

## Save the client ID and client secret to a file
$credentialsFilePath = 'C:\AzureAppCredentials.txt'
$credentialsContent = @"
AppKeyId: $clientId
AppSecretText: $clientSecret
"@

$credentialsContent | Out-File -FilePath $credentialsFilePath -Force

## Create the role assignment
New-AzRoleAssignment -RoleDefinitionName Contributor -ServicePrincipalName 'AppId'

#endregion

#region This goes in any script thereafter you need to authenticate to Azure into

## Create a PSCredential object from the application ID and password
$azureAppCred = (New-Object System.Management.Automation.PSCredential $appId, (Get-Content -Path $credentialsFilePath | ConvertTo-SecureString))

## Use the subscription ID, tenant ID and password to authenticate
$subscription = Get-AzSubscription -SubscriptName '<your subscription name>'
Add-AzAccount -ServicePrincipal -SubscriptionId $subscription.Id -TenantId $subscription.TenantId -Credential $azureAppCred
#endregion


