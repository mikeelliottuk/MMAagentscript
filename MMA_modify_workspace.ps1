#Powershell script to add or remove a Log Analytics workspace to the Microsoft Monitoring Agent
#Usage - MMA-modify-workspace -action (list/add/remove) -workspaceID -workspaceKey
#Mike Elliott - Nov 2020
#ver 2020_11_18_003

#initialise the script
param(
    [string] $action = "list",
    [string] $workspaceID = "",
    [string] $workspaceKey = ""
)

#check if the MMA agent service exists, exit the script if not
try {
$service=Get-Service 'HealthService' -ErrorAction Stop
}
catch
{
     Write-Output  "Error - $PSItem"
     Return 1
}

$mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
$usage = 'Syntax - MMA-modify-workspace [-action list/add/remove] [-workspaceID <String[]>] [-workspaceKey <String[]>]'

Switch ($action) #choose code based on the script action selected - default is list
{
 list {
    try {
        $currentWorkspaces = $mma.GetCloudWorkspaces() 
        if ($currentWorkspaces.length -ne 0 ){
            $currentWorkspaces
        }
        else {
            Write-Output 'No workspaces currently configured.'
        }
        return 0
    }
    catch{ #write the error to the console
        Write-Output $PSItem.ToString()
        return 1
    }
 }
 add { 
    try {
        #test for arguments workspaceID and workspaceKey
        if (($workspaceID -ne "") -and ($workspaceKey -ne "")){
            $mma.AddCloudWorkspace($workspaceId, $workspaceKey)
            $mma.ReloadConfiguration()
            Write-Output "New workspace $workspaceID added."
        }
        else {
            Write-Output $usage
        }
        return 0
    }
    catch{ #write the error to the console
        Write-Output $PSItem.ToString()
        return 1
    }
 }
 remove {
    try {
        #test for arguments workspaceID
        if ($workspaceID -ne ""){
            $mma.RemoveCloudWorkspace($workspaceId)
            $mma.ReloadConfiguration()
            Write-Output "Workspace $workspaceID removed."
        }
        else {
            Write-Output $usage
        }
        return 0
    }
    catch { #write the error to the console
        Write-Output $PSItem.ToString()
        return 1
    }
 }
 Default { $usage }
}
