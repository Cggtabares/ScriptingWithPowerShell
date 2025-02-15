#Project 6
#
#Creating a Syncing Script
#
#The key to build a great AD sync tool is sameness. By this, meant to create a script that can query each datastore the same way and have each 
#datastore return the same kind of object.
#
#The tricky part is when you have two different schemas, and you have to mappand transalte one filed name to another
#
#The script has the following process:
#This Syncing process, when triggered, roughly consist of the following six steps:
#1. Query external data source (SQL database, CSV file, and so forth)
#2. Retrieve objects from AD
#3. Find each object in the source that AD has a unique attribute to match on. This is usually referred to as an ID. 
#   The ID can be an employee ID or even usernames. The only thing that matters is that the attribute is unique. 
#   if no match is found, optionally create or remove the object from AD based on the source.
#4. Find a single matching object
#5. Map all external data sources to AD object attributes
#6. Modify existing AD objects or create a new ones.
#
#
#IN order to do this, you have to first: Mapping Data Source Attributes
#
#1. In the CSV you will have:
#First Name,Last Name,Department,Manager
#Adam,Bertram,IT,Miranda Bertram
#Barack,Obama,Executive Office,Michelle Obama
#Miranda,Bertram,Executive Office
#Michelle,Obama,Executive Office
#
#And you know the name attributes that are in the AD schema: GivenName, Surname, Department
#
#Mapping the Data Source Attributes
#
#Build a mapping hastable with the value for the CSV field as the key and the AD attribute name
$syncFieldMap = @{
   fname = 'GivenName'
   lname = 'Surname'
   dept = 'Department'
}
#
#Also you need to create an Unique ID for each employer
#
$fieldMatchIds = @{
    AD = @('givenName','surName')
    CSV = @('fname','lname')
}
#
#Second: Create Functions to Retunr Similar Properties
#
#This function maps and creates dynamically the properties based on the hashing maps, match to both datastore 
#
#declaring a function
function Get-AcmeEmployeeFromCsv {
    
    [CmdletBinding()]  #activating functions of advanced scripting
        param (        #parameters that the function will accept
            [Parameter()]      #declaring a parameter
            [string]$CsvFilePath = 'C:\Employees.csv', #the parameter will be type pf string and the parameter is typed

            [Parameter(Mandatory)]  #This parameter is mandatory
            [string]$SyncFieldMap,

            [Parameter(Mandatory)]
            [string]$FieldMatchIds
        )
        try{   #the actions of this function will be enclosed in a try/catch, in case the action results in an error, it won't fail the program, instead it will show the error and will continue the program
            
            $properties = $SyncFieldMap.GetEnumerator() | ForEach-Object { #Creating a variable properties, which inside has the enumerator gives you each key/value pair one after another for the $SyncFieldMap, the results will go to ForEach-Object since with enumerator cannot modified but with ForEach-Object, you can
                    @{   #initializing a hashmap and it will be filled with each iteration
                        Name = $_.Value  #first iteration will fill the Name with GivenName, then SurName, Department
                        Expression = [scriptblock]::Create("`$_.$($_.Key)") #For the expression it will create a scriptblock where it will save the value of the key of the current object 
                        #$_: This is an automatic variable in PowerShell that represents the current object in the pipeline.  Think of it as "the thing I'm currently working with."  It's often used in ForEach-Object loops or when processing the results of a command.

                        #. (Dot Operator):  The dot operator in PowerShell is used to access properties or methods of an object.  So, $_.Key means "get the value of the 'Key' property of the current object."

                        #$(...) (Subexpression Operator): The $(...) is the subexpression operator.  It takes whatever is inside the parentheses and executes it as a command or expression.  The result of that execution is then substituted in place of the $(...).

                        #$_.$($_.Key) (Putting it all together): This is where it gets interesting.  It's essentially saying "get the value of the property whose name is stored in the 'Key' property of the current object."  It's a dynamic property access.
                    
                    
                    }

            }

            $uniqueIdProperty = '"{0}{1}" -f '  #creates and initialize uniqueidProperty, where inside it saved the formatted to placeholders}
            $uniqueIdProperty = $uniqueIdProperty += ($FieldMatchIds.CSV | ForEach-object { '$_.{0}' -f $_ }) -join ',' #it will add first initialization with the values of the key (CSV) in each iteration and the it will use the placeholder to put the value and then it will join the resuls by a comma, ex: $_.{0} -f fname , the next iteration fname,lname

            $properties += @{  #Adding a new value to the hashmap
                   Name = 'UniqueID'   #adding the new property
                   Expression = [scriptblock]::Create($uniqueIdProperty)   #Expression that we created on the last variable
                   }
            
            #Read the CSV File and "transform" the CSV fields to AD attributes
            #So we can compare apples to apples
            Import-Csv -Path $CsvFilePath | Select-Object -Property $properties #Import CSV from the Path and the result will select the properties as row and will be change it as $properties
            


        } catch {
            Write-Error -Message $_.Exception.Message
        }

}

#
#
#Now you can call the function only by
#
#Get-AcmeEmployeeFromCsv -SyncFieldMap $syncFieldMap -FieldMatchIds $fieldMatchIds
#
#
#Third: Build a function that will query from AD

function Get-AcmeEmployeeFromAD {

    [CmdletBinding()]
    param (
            [Parameter(Mandatory)]
            [hashtable]$SyncFieldMap,

            [Parameter(Mandatory)]
            [hashtable]$FieldMatchIds
    )

    try {
            
        $uniqueIdProperty = '"{0}{1}" -f '
        $uniqueIdProperty += ($FieldMatchIds.AD | ForEach-Object { '$_.{0}' -f $_ }) -join '.'

        $uniqueIdProperty = @{
        
            Name = 'UniqueID'
            Expression = [scriptblock]::Create($uniqueIdProperty)
            
        }

        Get-ADUser -Filter * -Properties @($SyncFieldMap.Values) | Select-Object *,$uniqueIdProperty  #Command to get AD user - filter everything with the properties on syncfieldmap and the result will show all and uniqueIdProperty


    
    }catch { 
        
        Write-Error -Message $_.Exception.Message    
    
    }

        
}

#Fourth: Finding Matches in Active Directory
#
#Find all the matches between our CSV and AD
#
#
function Find-UserMatch {

    [OutputType()]
    [CmdletBinding()]
    param (
    
            [Parameter(Mandatory)]
            [hashtable]$SyncFieldMap,

            [Parameter(Mandatory)]
            [hashtable]$FieldMatchIds
    )

    $adUsers = Get-AcmeEmployeeFromAD -SyncFieldMap $SyncFieldMap -FieldMatchIds $FieldMatchIds

    $csvUsers = Get-AcmeEmployeeFromCsv -SyncFieldMap $SyncFieldMap -FieldMatchIds $FieldMatchIds

    $adUsers.forEach({
    
        $adUniqueId = $_.UniqueID  #initializing the variable with the current object property uniqueId

        if($adUniqueId) {  #this conditional evaluates if the variable is not empty, not zero, not null, not false will be enter 
         
             $output = @{  #initializing a hash table to save the results of every iteration that has something uniqueID
                    
                    CsvProperties = 'NoMatch'  
                    ADSamAccountName = $_.samAccountName  #to save the current object on property samAccountName
             }
             
             if ($adUniqueId -in $csvUsers.UniqueId) {         #Conditional where if adUniqueId is in $csvUsers.UniqueId (are equal)
             
                    $output.CsvProperties = ($csvUsers.Where({$_.UniqueId -eq $adUniqueId}))  #then it will save on the variable output inside csvProperties, the result of where in csvUsers where the current object property uniqueId is equal to adUniqueId

                       #example:
                       #$adUsers = @{
                               # name = 'name'
                               # UniqueId = 'nameUnique'
                       #}
                       #first iteration of the $adUsers.forEach({
                       
                                #$adUniqueid = nameUnique

                                #if($adUniqueId is not null){
                                    initialiaze the hashmap

                                   
                                   # if ($adUniqueId -in $csvUsers.UniqueId) {         #nameUnique is not inside the csvUsers.UniqueId but if it exist
             
                                        #       $output.CsvProperties = ($csvUsers.Where({$_.UniqueId -eq $adUniqueId}))  #it will look inside the csvUsers for the value of the current object property uniqueId is equal to $aduniqueId
                                
                                
                                #}


                       #})    
             
             }        

             [pscustomobject]$output   #it will output a customobject as variable output
        
        }



    })



}
#
#
#
Find-UserMatch -SyncFieldMap $syncFieldMap -FieldMatchIds $fieldMatchIds
#
#The result will be:
#ADSamAccountName     CSVProperties
#----------------     -------------
#user                 NoMatch
#abertram             {@{GivenName=Adam; Department=IT;
#                         Surname=Bertram; UniqueID=AdamBertram}}
#
#
#Fifth: Changing Active Directory Attributes
#
##Find all of the CSV <--> AD user account matches
$positiveMatches = (Find-UserMatch -SyncFieldMap $syncFieldMap -FieldMatchIds $fieldMatchIds).where({ $_.CsvProperties -ne 'NoMatch'})       #it will search inside the current object properties those are not the same as NoMatch and it will save it in positiveMatches
                # Runs Find-UserMatch cmdlet with two parameters: $syncFieldMap and $fieldMatchIds
                #Takes the results and filters out any entries where CsvProperties equals 'NoMatch'
                #Stores the filtered results in $positiveMatches

    forEach ($positiveMatch in $positiveMatches) {

              ##Create the splatting parameters for Set-ADUser using
              ##the identity of the AD samAccountName
              $setADUserParams = @{
                
                    Identity = $positiveMatch.ADSamAccountName
              
              }

              ##Read each property value that was in the CSV file
              $positiveMatch.Csvproperties.foreach({
              
                #Add a parameter to Set-ADUser for all of the CSV 
                #properties excluding UniqueId
                #Find all of the properties on the CSV row that are NOT uniqueId
                $_.PSObject.Properties.where({ $_.Name -ne 'UniqueId' }).foreach({ $setADUserParams[$_.Name] = $_.Value })
              
              })

              Set-ADUser @setADUserParams

    }