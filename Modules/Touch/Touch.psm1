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