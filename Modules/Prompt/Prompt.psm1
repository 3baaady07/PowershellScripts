function prompt 
{
  $p = Split-Path -leaf -path (Get-Location)
  
  Write-Host "$p`:" -BackgroundColor Green -ForegroundColor Black -NoNewLine
  
  $isGit = git rev-parse --is-inside-work-tree
  
  if($isGit)
  {
	  $currentBranch = git branch --show-current
	  Write-Host " git`:" -ForegroundColor Magenta -NoNewLine 
	  Write-Host "(" -BackgroundColor DarkBlue -ForegroundColor White -NoNewLine
	  Write-Host " $currentBranch " -BackgroundColor Red -ForegroundColor Black -NoNewLine
	  Write-Host ")" -BackgroundColor DarkBlue -ForegroundColor White -NoNewLine
	  
	  $uncommittedChanges = git status -z
	  if(-not ([string]::IsNullOrEmpty($uncommittedChanges)))
	  {
		  Write-Host " *" -ForegroundColor Yellow
	  }
	  else
	  {
		  Write-Host
	  }
  }
  else
  {
	  #Remove the trivial error result from git rev-parce command
	  $ERROR.Remove($ERROR[0])
  }
  
  " > "
}