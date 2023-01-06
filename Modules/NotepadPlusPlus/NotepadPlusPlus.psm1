function notepad++
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$ComputerName
    )
    
    Start notepad++ $ComputerName
}