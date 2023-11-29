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

function Restart-InterfaceStatus {
    param(
        [string]$PiServer = "MGTPPI01",
        [string]$InterfaceName,
        $Time
    )

    # Connect to PI Server
    $piConnection = Connect-PIDataArchive -PIDataArchiveMachineName $PiServer

    # Get interface PIPoint
    $interfacePoint = Get-PIPoint -Name $InterfaceName -Connection $piConnection
    $interfaceValue = Get-PIValue -PIPoint $interfacePoint -Time $Time -ArchiveMode Previous

    # Check if status is 'Primary'
    if ($interfaceValue.Value -eq '99 | Intf Shutdown') {
        Write-Host "Starting process of restart"
        Restart-Service $InterfaceName
        Write-Host "---ending of process---"
    } else {
        Write-Host "PI is good"
    }
}

$globalRelativeStartTimePI = '*'

Restart-InterfaceStatus -InterfaceName "sy.st.PI2201A.PSI_OPCA1.Device Status" -Time (ConvertFrom-AFRelativeTime $globalRelativeStartTimePI)



