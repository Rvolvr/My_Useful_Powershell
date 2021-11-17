$machine = read-host "Set computer from which to list users"
#Pull information from machine, filter out non-domain users
$collection = Get-CimInstance -ClassName Win32_UserProfile -ComputerName $machine | Where-Object {$_.SID -match "S-1-5-21"}
#Pull the name of the active user
$active = Get-WmiObject -Class Win32_ComputerSystem -computername $machine | Select-Object UserName
#clean up the active user information
$name = $($active.UserName -split '\\')[1]
Write-Warning -Message "$name is currently logged in"
#Start the selection menu
[INT]$profile = '0'
foreach ($item in $collection) {
    $opt = ($item.localpath -split '\\')[2]
    If ($name -ne $opt) {
        Write-Output "$profile $opt"
    }else{
        Write-Warning -Message "Cannot select $name - Active User"
        $disallowed = $profile
    }
    $profile ++
}
$profile --
[int]$selection = Read-Host "Make a selection"
#Prevent active user from selection, then remove identified user
if ($selection -le $profile) {
    
    If ($selection -ne $disallowed){
        Write-Output -Message "Selecting user $($collection[$selection].LocalPath) in $machine for removal"
        Remove-CimInstance -computername $machine $collection[$selection] -Confirm
    } Else {
        Write-Error -Message "Cannot delete Active user"
    }
} Else {
    Write-Error -Message "$selection was not a valid input. Options go to $profile."
}