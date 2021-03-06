############################################################################################################################################
# Script that allows to load data from a CSV file in a SharePoint Contacts list
# Required parameters
#   ->$siteUrl: Site Coleccion Url
#   ->$sListName: Contacts List Name
############################################################################################################################################
If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Current Path
$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path

#Required Parameters
$sSiteUrl = “http://norbert_pre/sites/Intranet/”
$sColumnName="Lastname"

#Variables necesarias para la carga de datos
$sLastnameField="Title"
$sFirstnameField="FirstName"
$sEMailField="Email"

#Definition of the function that allows to load data in a SharePoint Contacts list
function Load-ContactListData
{
    param ($sListName, $sInputFile, $sColumnName)    
    try
    {
        $spSite = Get-SPSite -Identity $sSiteUrl
        $spWeb = $spSite.OpenWeb()
        
        #Checking if the list exists
        $lList=$spWeb.Lists[$sListName]
        If (($lList)) 
        {         
            # Verifying if the CSV file exists
            $bFileExists = (Test-Path $sInputFile -PathType Leaf) 
            if ($bFileExists) { 
                "Loading $InvFile file for data processing..." 
                $tblDatos = Import-CSV $sInputFile            
            } else { 
                Write-Host "$sInputFile file not found.Stopping the loading process!" -foregroundcolor Red
            exit 
            } 
                    
            Write-Host "Loading data in the list $sListName ..." -foregroundcolor Green    
            foreach ($fila in $tblDatos) 
            { 
                "Adding record " + $fila.$sColumnName.ToString() 
                $spItem = $lList.AddItem()                 
                #Last name                                
                $spItem[$sLastnameField] = $fila.$sColumnName.ToString()
                #Firstname                               
                $spItem[$sFirstnameField] = $fila.Firstname.ToString()
                #E-Mail
                $spItem[$sEMailField] = $fila.EMail.ToString()
                $spItem.Update() 
            } 

            Write-Host "-----------------------------------------"  -foregroundcolor Blue
            Write-Host "Import process completed!!" -foregroundcolor Blue
        
        }else
        {
            Write-Host "The list $sListName doesn't exist ..." -foregroundcolor Red
            exit
        }        
        #Object disposal
        $spWeb.Dispose()
        $spSite.Dispose()     
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
# CSV file with the data to be loaded
$sInputFile=$ScriptDir+ "\ContactsListData.csv"

Load-ContactListData -sListName "Contactos" -sInputFile $sInputFile -sColumnName $sColumnName

Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell