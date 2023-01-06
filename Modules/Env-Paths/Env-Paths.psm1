function env-paths()
{
	$env:Path.Replace(";",[System.Environment]::NewLine)
}