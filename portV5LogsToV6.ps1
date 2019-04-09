# Ports logs from the version <5.XX and organises them into the new structure

$logDir = "C:\Gcloud\GcloudLogs"

[array]$files = Get-ChildItem "$logDir\*.txt" | select -expand fullname

foreach ($file in $files) {

	$fileDate = ($file -Split "_")[1] -Replace "\..*$"
	
	try { 
		mv "$file" "$logDir\$fileDate\" -ErrorAction Stop	
	}
	catch [System.IO.IOException] {
		mkdir "$logDir\$fileDate" -ErrorAction Continue 2>&1> $null			
		mv "$file" "$logDir\$fileDate\" -ErrorAction Continue
	}
	
}
		

