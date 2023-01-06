function base64 ( $code )
{
	[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($code))
}