# Ports logs from the version <5.XX and organises them into the new structure

$logDir = "C:\Gcloud\GcloudLogs"

try {

	[array]$files = Get-ChildItem "$logDir\*.txt" | select -expand fullname
	
	foreach ($file in $files) {
		$fileDate = ($file -Split "_")[1] -Replace "\..*$"
		
		mkdir "$logDir\$fileDate" -ErrorAction Stop 2>&1> $null
		mv "$file" "$logDir\$fileDate\" -ErrorAction Stop	
	}
		
}
catch {
	Write-Host 'Unknown error. Caught exception:' $_.Exception.GetType().FullName -fore red -back black
}
