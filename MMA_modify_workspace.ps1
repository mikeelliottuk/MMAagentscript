#Powershell script to add or remove a Log Analytics workspace to the Microsoft Monitoring Agent
#Usage - MMA-modify-workspace -action (list/add/remove) -workspaceID -workspaceKey

#initialise the script
param(
    [string] $action = "list",
    [string] $workspaceID = "",
    [string] $workspaceKey = ""
)
$mma = New-Object -ComObject 'AgentConfigManager.MgmtSvcCfg'
$usage = "Usage - MMA-modify-workspace -action (list/add/remove) -workspaceID -workspaceKey’"

Switch ($action) #choose code based on the script action selected - default is list
{
 list {
    $currentWorkspaces = $mma.GetCloudWorkspaces()
    if ($currentWorkspaces.length -ne 0 ){
        $currentWorkspaces
        }
    else {
        Write-Output 'No workspaces currently configured.'
    }
 }
 add { 
    
    #test for arguments workspaceID and workspaceKey
    if (($workspaceID -ne "") -and ($workspaceKey -ne "")){
        $mma.AddCloudWorkspace($workspaceId, $workspaceKey)
        $mma.ReloadConfiguration()
        Write-Output "New workspace $workspaceID added."
    }
    else {
        Write-Output $usage
    }

 }
 remove {
    $mma.RemoveCloudWorkspace($workspaceId)
    $mma.ReloadConfiguration()
    Write-Output "Workspace $workspaceID removed."
 }
 Default { $usage }
}
