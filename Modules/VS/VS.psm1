function vs ( $path )
{
	if( Test-Path $path\*.sln )
	{
		invoke-item $path\*.sln;
	}
	else
	{
		Write-Error -Exception ([System.IO.FileNotFoundException]::new("Cannot find a solution file.")) `
		-Category ObjectNotFound `
		-ErrorAction Stop `
		-CategoryActivity "Invoke-Item"
	}
}