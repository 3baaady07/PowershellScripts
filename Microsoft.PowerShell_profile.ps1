# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) 
{
  Import-Module "$ChocolateyProfile"
}

if (Test-Path(".\Modules\DockerCompletion"))
{
    Import-Module DockerCompletion
}

if (Test-Path(".\Modules\posh-git"))
{
    Import-Module posh-git
}

Import-Module Prompt


# function prompt 
# {
#   $p = Split-Path -leaf -path (Get-Location)
  
#   Write-Host "$p`:" -BackgroundColor Green -ForegroundColor Black -NoNewLine
  
#   $isGit = git rev-parse --is-inside-work-tree
  
#   if($isGit)
#   {
# 	  $currentBranch = git branch --show-current
# 	  Write-Host " git`:" -ForegroundColor Magenta -NoNewLine 
# 	  Write-Host "(" -BackgroundColor DarkBlue -ForegroundColor White -NoNewLine
# 	  Write-Host " $currentBranch " -BackgroundColor Red -ForegroundColor Black -NoNewLine
# 	  Write-Host ")" -BackgroundColor DarkBlue -ForegroundColor White -NoNewLine
	  
# 	  $uncommittedChanges = git status -z
# 	  if(-not ([string]::IsNullOrEmpty($uncommittedChanges)))
# 	  {
# 		  Write-Host " *" -ForegroundColor Yellow
# 	  }
# 	  else
# 	  {
# 		  Write-Host
# 	  }
#   }
#   else
#   {
# 	  #Remove the trivial error result from git rev-parce command
# 	  $ERROR.Remove($ERROR[0])
#   }
  
#   " > "
# }

function notepad++{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$ComputerName
    )

    Start notepad++ $ComputerName
}

function vs ( $path )
{
	if( Test-Path $path\*.sln )
	{
		invoke-item $path\*.sln;
	}
	else
	{
		Write-Error -Exception ([System.IO.FileNotFoundException]::new("Cannot find a solution file because it does not exist.")) `
		-Category ObjectNotFound `
		-ErrorAction Stop `
		-CategoryActivity "Invoke-Item"
	}
}

$global:firstDir=pwd
$global:secondDir=""
function go ( $path )
{
	if([string]::IsNullOrEmpty($path))
	{
		go ~
	}
    elseif($path -eq '.')
	{
		if(-not ([string]::IsNullOrEmpty($global:secondDir)))
		{
			go  $global:secondDir
		}
	}
	else
	{
		if( Test-Path $path )
		{
			$global:secondDir=$global:firstDir
			$path=Get-Item $path | Select-Object PSPath -ExpandProperty PSPath
			$global:firstDir=$path.Substring(38)
			Set-Location $global:firstDir
		}
		else
		{
			Write-Error -Exception ([System.IO.FileNotFoundException]::new("Cannot find path '$path' because it does not exist.")) `
			-Category ObjectNotFound `
			-ErrorAction Stop `
			-CategoryActivity "Set-Location"
		}
	}
}
Remove-Item Alias:cd
Set-Alias -Name cd -Value go


Function Get-DirectoryTreeSize {
<#
.SYNOPSIS
    This is used to get the file count, subdirectory count and folder size for the path specified. The output will show the current folder stats unless you specify the "AllItemsAndAllFolders" property.
    Since this uses Get-ChildItem as the underlying structure, this supports local paths, network UNC paths and mapped drives.
 
.NOTES
    Name: Get-DirectoryTreeSize
    Author: theSysadminChannel
    Version: 1.0
    DateCreated: 2020-Feb-11
 
 
.LINK
    https://thesysadminchannel.com/get-directory-tree-size-using-powershell -
 
 
.PARAMETER Recurse
    Using this parameter will drill down to the end of the folder structure and output the filecount, foldercount and size of each folder respectively.
 
.PARAMETER AllItemsAndAllFolders
    Using this parameter will get the total file count, total directory count and total folder size in MB for everything under that directory recursively.
 
.EXAMPLE
    Get-DirectoryTreeSize "C:\Some\Folder"
 
    Path            FileCount DirectoryCount FolderSizeInMB
    ----            --------- -------------- --------------
    C:\Some\folder          3              3          0.002
 
.EXAMPLE
    Get-DirectoryTreeSize "\\MyServer\Folder" -Recurse
 
    Path                 FileCount DirectoryCount FolderSizeInMB
    ----                 --------- -------------- --------------
    \\MyServer\Folder            2              1         40.082
    .\Subfolder                  1              0         26.555
 
.EXAMPLE
    Get-DirectoryTreeSize "Z:\MyMapped\folder" -AllItemsAndAllFolders
 
    Path                  TotalFileCount TotalDirectoryCount TotalFolderSizeInMB
    ----                  -------------- ------------------- -------------------
    Z:\MyMapped\folder                 3                   1              68.492
 
#>
 
[CmdletBinding(DefaultParameterSetName="Default")]
 
param(
    [Parameter(
        Position = 0,
        Mandatory = $true
    )]
    [string]  $Path,
 
 
 
    [Parameter(
        Mandatory = $false,
        ParameterSetName = "ShowRecursive"
    )]
    [switch]  $Recurse,
 
 
 
    [Parameter(
        Mandatory = $false,
        ParameterSetName = "ShowTopFolderAllItemsAndAllFolders"
    )]
    [switch]  $AllItemsAndAllFolders
)
 
    BEGIN {
        #Adding a trailing slash at the end of $path to make it consistent.
        if (-not $Path.EndsWith('\')) {
            $Path = "$Path\"
        }
    }
 
    PROCESS {
        try {
            if (-not $PSBoundParameters.ContainsKey("AllItemsAndAllFolders") -and -not $PSBoundParameters.ContainsKey("Recurse")) {
                $FileStats = Get-ChildItem -Path $Path -File -ErrorAction Stop | Measure-Object -Property Length -Sum
                $FileCount = $FileStats.Count
                $DirectoryCount = Get-ChildItem -Path $Path -Directory | Measure-Object | select -ExpandProperty Count
                $SizeMB =  "{0:F3}" -f ($FileStats.Sum / 1MB) -as [decimal]
 
                [PSCustomObject]@{
                    Path                 = $Path#.Replace($Path,".\")
                    FileCount            = $FileCount
                    DirectoryCount       = $DirectoryCount
                    FolderSizeInMB       = $SizeMB
                }
            }
 
            if  ($PSBoundParameters.ContainsKey("AllItemsAndAllFolders")) {
                $FileStats = Get-ChildItem -Path $Path -File -Recurse -ErrorAction Stop | Measure-Object -Property Length -Sum
                $FileCount = $FileStats.Count
                $DirectoryCount = Get-ChildItem -Path $Path -Directory -Recurse | Measure-Object | select -ExpandProperty Count
                $SizeMB =  "{0:F3}" -f ($FileStats.Sum / 1MB) -as [decimal]
 
                [PSCustomObject]@{
                    Path                 = $Path#.Replace($Path,".\")
                    TotalFileCount       = $FileCount
                    TotalDirectoryCount  = $DirectoryCount
                    TotalFolderSizeInMB  = $SizeMB
                }
            }
 
            if ($PSBoundParameters.ContainsKey("Recurse")) 
			{
                Get-DirectoryTreeSize -Path $Path
                $FolderList = Get-ChildItem -Path $Path -Directory -Recurse | select -ExpandProperty FullName
 
                if ($FolderList)
				{
                    foreach ($Folder in $FolderList)
					{
                        $FileStats = Get-ChildItem -Path $Folder -File | Measure-Object -Property Length -Sum
                        $FileCount = $FileStats.Count
                        $DirectoryCount = Get-ChildItem -Path $Folder -Directory | Measure-Object | select -ExpandProperty Count
                        $SizeMB =  "{0:F3}" -f ($FileStats.Sum / 1MB) -as [decimal]
 
                        [PSCustomObject]@{
                            Path                 = $Folder.Replace($Path,".\")
                            FileCount            = $FileCount
                            DirectoryCount       = $DirectoryCount
                            FolderSizeInMB       = $SizeMB
                        }
                        #clearing variables
                        $null = $FileStats
                        $null = $FileCount
                        $null = $DirectoryCount
                        $null = $SizeMB
                    }
                }
            }
        } 
		catch
		{
            Write-Error $_.Exception.Message
        }
 
    }
 
    END {}
}

function touch( $path )
{
	if( Test-Path $path )
	{
		(Get-Item $path).LastWriteTime = Get-Date
	}
	else
	{
		ni $path
	}
}

function base64 ( $code )
{
	[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($code))
}

Set-Alias -Name grep -Value Select-String

Set-Alias -Name inv -Value Invoke-Item

function scb-path( )
{
	pwd -OutVariable p | scb
}

function env-paths()
{
	$env:Path.Replace(";",[System.Environment]::NewLine)
}

function get-parent($path)
{
	Split-Path $path
}