#Run script as Administrator
Function Check-RunAsAdministrator(){
$CurrentUser = New-Object Security.Principal.windowsPrincipal $([Security.Principa.windowsIdentity]::GetCurrent())
    if ($CurrentUser.IsInRole([Security.Principal.windowsBuiltinRole])::Administrator)
            {
        Write-host "Script is running with Administrator privileges !"
            }
    else {

        $ElevatedProcess = New-object System.Diagnostics.ProcessStartInfo "PowerShell";
        $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
        $ElevatedProcess.Verb="runas"
        [System.Diagnostics.Process]::Start($ElevatedProcess)
        Exit

        }

        }

#Add content in the logfile
Function Interface-Log-Messages(
[Parameter (Mandatory)]
[string]$InterfaceName,
[Parameter (Mandatory)]
[String]$Message
)
{
    $Directory="C:\PI Scripts\InterfaceLogs"
    $LogFile = "$($Directory)\$($InterfaceName).txt"
    if (!(Test-Path $Directory)) {
    New-Item $Directory -ItemType Directory
    }
    if (!(Test-Path $LogFile)){
    New-Item -path $Directory -name "$($InterfaceName).txt" -type "file"
    }

    Try {
    $TimeStamp= (Get-Date).ToString("dd/MM/yyyy HH:mm;ss:fff tt")
    $Line="[$(TimeStamp)] - $($TimeStamp)"
    Add-Content -Path $LogFile -Value $Line
         }
    catch {
    write-host -f Red "Error:" $_.Exception.Message
    }
}
#Restart interface if Pi2201A is Backup and Pi2201B is Primary

Function Restart-Interface (
[string] $piserver = "MGTPPI01",
[Parameter (Mandatory)][string] $InterfaceDisplayName,
[Parameter (Mandatory)] [string] $piPointName1,
[Parameter (Mandatory)] [string] $piPointName2,
[Parameter (Mandatory)] $Time

)
{
 $piConnection = Connect-PIDataArchive -PIDataArchiveMachineName $piServer;
 $piPoint1 = Get-PIPoint -Name $piPointName1 -Connection $piConnection;
 $piPoint2 = Get-PIPoint -Name $piPointName2 -Connection $piConnection;
 $piPointValue1 = Get-PIValue -PIPoint $piPoint1 -Time $Time -ArchiveMode Previous
 $piPointValue2 = Get-PIValue -PIPoint $piPoint2 -Time $Time -ArchiveMode Previous


Interface-Log-Messages -InterfaceName $InterfaceDisplayName -Message "|------Checking if Pi2201A is $($piPointName1) and Pi220B$ ($piPointName2) is on Backup---|"

if($piPointValue1.Value.State -ne 'Backup' -and $piPointValue2.Value.State -ne 'Primary')

{
Interface-Log-Messages -InterfaceName $InterfaceDisplayName -Message "----Interface is on the bad Condition---"
Interface-Log-Messages -InterfaceName $InterfaceDisplayName -Message "|------------- Starting process of restart -------------|"
Restart-Service -DisplayName $interfaceDisplayName
Interface-Log-Message -InterfaceName $interfaceDisplayName -Message "Interface has been restarted...!"
Interface-Log-Message -InterfaceName $interfaceDisplayName -Message "|-------------- Ending process of restart -------------|"
}
else  {

Interface-Log-Message -InterfaceName $interfaceDisplayName -Message "----Interface is on the good Condition---"

    }
Interface-Log-Message -InterfaceName $interfaceDisplayName -Message "|------------------------- End of checking process --------------------|"

}
$globalRelativeStartTimePI = '*'

Check-RunAsAdministrator
#Restart-Interface -InterfaceDisplayName "PI Message Subsystem" -piPointName1 "MGTPPI01-opcint_1_PSI_UFO2_State_1"  -Time (ConvertFrom-AFRelativeTime $globalRelativeStartTimePI)
Restart-Interface -InterfaceDisplayName "PI Message Subsystem" -piPointName2 "MGTPPI01-opcint_1_PSI_UFO2_State_2"  -Time (ConvertFrom-AFRelativeTime $globalRelativeStartTimePI)