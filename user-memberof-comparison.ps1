$FirstUser = Read-Host "Enter The First User"
while(!($FirstUser -like "*.*") -or !(Get-ADUser -Filter {samaccountname -eq $FirstUser}))
{

    $FirstUser = Read-Host "Invalid input. Enter The First User again."

}


$SecondUser = Read-Host "Enter The Second User"
while(!($SecondUser -like "*.*") -or !(Get-ADUser -Filter {samaccountname -eq $SecondUser}))
{

    $SecondUser = Read-Host "Invalid input. Enter The Second User again."

}


$FirstUGM = (get-aduser -identity $FirstUser -Properties memberof).memberof
$SecondUGM = (get-aduser -identity $SecondUser -Properties memberof).memberof
$FirstMissings = @()
$SecondMissings = @()

foreach ($S in $SecondUGM)
{
    $SGroupName = (get-adobject $S).name
    $SGroupDName = (get-adobject $S)
    $Matched = $False
    foreach ($F in $FirstUGM)
    {
        $FGroupName = (get-adobject $F).name
        if ($SGroupName -eq $FGroupName){$Matched = $True;break}
    }
    if ($Matched -eq $False){
    
        write-host "$FirstUser is not a member of $SGroupName"
        $FirstMissings += $SGroupDName

        
        }
}

foreach ($F in $FirstUGM)
{
    $FGroupName = (get-adobject $F).name
    $FGroupDName = (get-adobject $F)
    $Matched = $False
    foreach ($S in $SecondUGM)
    {
        $SGroupName = (get-adobject $S).name
        if ($FGroupName -eq $SGroupName){$Matched = $True;break}
    }
    if ($Matched -eq $False){
        write-host "$SecondUser is not a member of $FGroupName"
        $SecondMissings += $FGroupDName
        
        
    }
}

if($FirstMissings.Length -eq 0 -and $SecondMissings.Length -eq 0)
{
    Write-Host "There is no difference between users"
    break

}

elseif($FirstMissings.Length -ne 0 -and $SecondMissings.Length -eq 0)
{
    Write-Host "There is no missing group for $SecondUser"
    Write-Host "The process will continue to add groups to $FirstUser"
    $Ask = 1
}

elseif($FirstMissings.Length -eq 0 -and $SecondMissings.Length -ne 0)
{
    Write-Host "There is no missing group for $FirstUser"
    Write-Host "The process will continue to add groups to $SecondUser"
    $Ask = 2
}
elseif(!($FirstMissings.Length -eq 0 -and $SecondMissings.Length -eq 0))
{

    $Ask = Read-Host "Which user you want to add a group? 1: $FirstUser or 2: $SecondUser"
    while(!(($Ask -eq "1") -or ($Ask -eq "2")))
    {

        $Ask = Read-Host "Invalid input. You have to choose 1: $FirstUser or 2: $SecondUser"
    
    }


}

else{Write-Host "There is an error"}


$i = 1
if ($ask -eq "1")
{
    foreach( $item in $FirstMissings)
{
        
        Write-Host $i - $item.name
        $i = $i + 1
    
    }
    $which = Read-Host "Which group you want to add to $FirstUser"
    $which = $which.Split(" ")
    $whichmax = ($which | measure -Maximum).Maximum
    $whichmin = ($which | measure -Minimum).Minimum 
    while(!(($whichmin -ge 1) -and ($whichmax -le $FirstMissings.Length)))
    {
        $which = Read-Host "Invalid input. Which group you want to add to $FirstUser again."
        $which = $which.Split(" ")
        $whichmax = ($which | measure -Maximum).Maximum
        $whichmin = ($which | measure -Minimum).Minimum 

    }
    
    foreach($num in $which)
    {
        $num = $num - 1
        Add-ADGroupMember -Identity $FirstMissings[$num] -Members $FirstUser

    }

}
elseif ($ask -eq "2"){
    foreach( $item in $SecondMissings){
        
        Write-Host $i - $item.name
        $i = $i + 1
    
    }
    $which = Read-Host "Which group you want to add to $SecondUser"
    $which = $which.Split(" ")
    $whichmax = ($which | measure -Maximum).Maximum
    $whichmin = ($which | measure -Minimum).Minimum 
    while(!(($whichmin -ge 1) -and ($whichmax -le $SecondMissings.Length)))
    {
        $which = Read-Host "Invalid input. Which group you want to add to $SecondUser again."
        $which = $which.Split(" ")
        $whichmax = ($which | measure -Maximum).Maximum
        $whichmin = ($which | measure -Minimum).Minimum 

    }

    foreach($num in $which)
    {
        $num = $num - 1
        Add-ADGroupMember -Identity $SecondMissings[$num] -Members $SecondUser

    }

}

Write-Host "Process is done."
