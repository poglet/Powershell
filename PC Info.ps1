$Computer = "#######"

# DEFINE PROPERTIES: win32_bios
    $PCBios = Get-WmiObject -computername $Computer -Class win32_bios | select-object *

        $PCSerialNo = $PCBios.SerialNumber

# DEFINE PROPERTIES: Win32_OperatingSystem
    $OSProperties = Get-WMIObject -computername $Computer -Class Win32_OperatingSystem
        
        $OSCaption = $OSproperties.Caption
        $OSTotalMemory = "{0:0}" -f ($OSproperties.TotalVisibleMemorySize / 1024)
        $OSFreeMemory = "{0:0}" -f ($OSproperties.FreePhysicalMemory / 1024)
        $OSUsersNo = $OSproperties.NumberOfUsers
        $OSInstallDate = $OSproperties.ConvertToDateTime($OSproperties.InstallDate)
        $OSLastBoot = $OSproperties.ConvertToDateTime($OSproperties.LastBootUpTime)
            $TimeLastBoot = NEW-TIMESPAN –Start $OSLastBoot –End (GET-DATE)


# DEFINE PROPERTIES: Win32_ComputerSystem
    $PCSystem = Get-WmiObject -computername $Computer -Class Win32_ComputerSystem  | select-object *

        $PCModel = $PCSystem.Model
        $PCUser = ($PCSystem.UserName).Split('\')[1]

# DEFINE PROPERTIES: Get-WMIObject & get-process, combined

    $owners = @{}
    Get-WMIObject -computername $Computer -Class win32_process |
    % {$owners[$_.handle] = $_.getowner().user}

    $PCProcesses = get-process | 
        select @{l="Owner";e={$owners[$_.id.tostring()]}}, ID,ProcessName, @{Name="PM(MB)";Expression={[math]::truncate($_.PM / 1MB)}} |
        Sort-Object "PM(MB)" -Descending |
        Select-Object -First 5 | Format-Table -AutoSize


# DEFINE PROPERTIES: Win32_DiskDrive
    $PCPartition = Get-WmiObject -computername $Computer Win32_DiskDrive   | select-object *

# DEFINE PROPERTIES: Win32_LogicalDisk
    $PCHarddrive = Get-WmiObject -computername $Computer -Class Win32_LogicalDisk |
       Select-Object @{Name="Drive";Expression={($_.DeviceID)}}, @{Name="Total(GB)";Expression={[math]::truncate($_.Size / 1GB)}}, @{Name="Free(GB)";Expression={[math]::truncate($_.FreeSpace / 1GB)}}, ProviderName |
       Where-Object  {$_.'Total(GB)' -gt ''} |
       Format-Table -AutoSize

# DEFINE PROPERTIES: Win32_NetworkAdapterConfiguration
    $PCNetwork =    Get-WMIObject -computername $Computer -Class Win32_NetworkAdapterConfiguration | Select-Object * | Where-Object {$_.IPAddress -Like '*.*'}

        $PCAdapterDesc = $PCNetwork.Description
        $PCMACAdd = $PCNetwork.MACAddress
        $PCIPAdd = $PCNetwork.IPAddress
        $PCGateway = $PCNetwork.DefaultIPGateway
        $PCDNSDomain = $PCNetwork.DNSDomain


# DEFINE PROPERTIES: Win32_Share
    $PCShares = Get-WMIObject -computername $Computer -Class Win32_Share | Select-Object Path, Name, Description | Format-Table -AutoSize

# DEFINE PROPERTIES: Win32_SystemDriver
    $PCDrivers = Get-WMIObject -computername $Computer -Class Win32_SystemDriver |
        Where-Object {$_.State -Like 'Running'} |
        Select-Object Name, DisplayName |
        Sort-Object DisplayName -Descending |
        Format-Table -AutoSize


# Output below here

cls
$Computer
Write-Host $PCModel $PCSerialNo
$OSCaption
Write-Host
Write-Host "OS Install Date : $OSInstallDate"
Write-Host "Last Boot Time  : "$TimeLastBoot.Days" days "$TimeLastBoot.Hours" hours"
Write-Host
Write-Host "Adapter         : $PCAdapterDesc"
Write-Host "MAC             : $PCMACAdd"
Write-Host "IP              : $PCIPAdd"
Write-Host "Gateway         : $PCGateway"
Write-Host "Domain          : $PCDNSDomain"

$PCHarddrive
Write-Host "Available RAM   : $OSFreeMemory of $OSTotalMemory"
$PCProcesses
Write-Host

    $ADUser = $PCUser | Get-ADUser -Properties *
    $GivenName = $ADUser.GivenName
    $Surname = $ADuser.Surname

Write-Host "$GivenName $Surname - $PCUser"
Write-Host $ADUser.Office", "$ADuser.Description
Write-Host "H Drive:" $ADUser.HomeDirectory
Write-Host
