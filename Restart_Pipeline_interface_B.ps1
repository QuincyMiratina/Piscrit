Function Check-RunAsAdministrator(){
    $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    if($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)){
       Write-host "Script is running with Administrator privileges!"
    }
    else{
       $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
       $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
       $ElevatedProcess.Verb = "runas"
       [System.Diagnostics.Process]::Start($ElevatedProcess)
       Exit
    }
}
<#
Function Restart-Interface-Statu(
[string]$piServer = "MGTPPI01",
    #[Parameter(Mandatory)]
	#[string]$interfaceDisplayName,
    [Parameter(Mandatory)]
	[string]$piPointName,
    [Parameter(Mandatory)]
    [string]$Statu,
    [Parameter(Mandatory)]
	$Time
)
{
#----------------------------Connection to Piserver----------------------------------------
        $piConnection = Connect-PIDataArchive -PIDataArchiveMachineName $piServer;
#----------------------------Statu connection to piarchive----------------------------------
     $piPointStatu =  Get-PIPoint -Name $Statu -Connection $piConnection;
     $piPointStatuValue = Get-PIValue -PIPoint $piPointStatu #-Time $Time -ArchiveMode Previous
#-----------------------------PiPoint connection to piarchive--------------------------------  
     
     $piPoint = Get-PIPoint -Name $piPointName -Connection $piConnection;
     $piPointValue = Get-PIValue -PIPoint $piPoint -Time $Time -ArchiveMode Previous
#-----------------------------Check if Bravo is Primary--------------------------------------

    if($piPointStatuValue.Value -ne 'Primary')
    {
     Write-host "Starting process of restart"
     Restart-Service $piPointName 
     Write-Host "---ending of process---"

}

else {
Write-host "pi is good"
}

}
#>
function Restart-InterfaceStatus {
    param(
        [string]$PiServer = "MGTPPI01",
        [string]$InterfaceName,
        [string]$Status,
        $Time
    )

    # Connect to PI Server
    $piConnection = Connect-PIDataArchive -PIDataArchiveMachineName $PiServer

    # Get status PIPoint
    $statusPoint = Get-PIPoint -Name $Status -Connection $piConnection
    $statusValue = Get-PIValue -PIPoint $statusPoint

    # Get interface PIPoint
    $interfacePoint = Get-PIPoint -Name $InterfaceName -Connection $piConnection
    $interfaceValue = Get-PIValue -PIPoint $interfacePoint -Time $Time -ArchiveMode Previous

    # Check if status is 'Primary'
    if ($statusValue.Value -eq 'Primary') {
        Write-Host "Starting process of restart"
        Restart-Service $InterfaceName
        Write-Host "---ending of process---"
    } else {
        Write-Host "PI is good"
    }
}

$globalRelativeStartTimePI = '*'
Check-RunAsAdministrator
Restart-InterfaceStatus -InterfaceName "sy.st.PI2201B.PSI_OPCB1.Device Status" -Status "MGTPPI01-opcint_1_PSI_UFO2_State_2" -Time (ConvertFrom-AFRelativeTime $globalRelativeStartTimePI)



