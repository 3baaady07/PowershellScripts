function get-parent($path)
{
	Split-Path -Parent $path
}