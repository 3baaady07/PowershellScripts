Import-Module Prompt

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

if (Test-Path( get-parent($PROFILE) + "\Modules\DockerCompletion"))
{
	Import-Module DockerCompletion
}

if (Test-Path(get-parent($PROFILE) + "\Modules\posh-git"))
{
	Import-Module posh-git
}

if (Test-Path("C:\Users\$env:USERNAME\AppData\Local\Programs\Terraform\"))
{
	Add-PathVariable C:\Users\$env:USERNAME\AppData\Local\Programs\Terraform\
}

Remove-Item Alias:cd

$global:firstDir=$PWD
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
Set-Alias -Name cd -Value go -Option AllScope

Set-Alias -Name grep -Value Select-String
Set-Alias -Name inv -Value Invoke-Item