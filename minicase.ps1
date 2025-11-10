[CmdletBinding()]
param (
    [Parameter()]
    [int]
    $Value1

    ,[Parameter()]
    [int]
    $Value2
)

$Array = ($Value1, $Value2)

Write-Host "Calculating the sum of Array."
$Sum = 0
foreach ($i in $Array ) {
    $Sum += $i
}
Write-Host "The sum of $Value1 and $Value2 is $Sum."