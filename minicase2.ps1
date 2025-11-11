param (
    [Parameter()]
    [int]
    $Value1

    ,[Parameter()]
    [int]
    $Value2
)

if ( $Value1 % 3 -eq 0 -and $Value2 % 5 -eq 0 ) {
    write-host "fubar"
}
elseif ( $Value1 % 3 -eq 0 ) {
    Write-Host "fu"
}
else {
    write-host "bar"
}
