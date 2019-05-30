$User = "hidalgosgroupSL@gmail.com"
$File = ".\MailPassword.txt"
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString)
$EmailTo = "informatica@hidalgosgroup.com"
$EmailFrom = "hidalgosgroupSL@gmail.com"
$Subject = "Test Mailing - Gcloud Backups" 
$Body = "<h2>This is a test, ignore this message, bitches.</h2><br><br>Saludos, TOPOTAMADRE." 

$SMTPServer = "smtp.gmail.com" 

$SMTPMessage = New-Object System.Net.Mail.MailMessage($EmailFrom,$EmailTo,$Subject,$Body)
$SMTPMessage.isBodyHTML = $true

$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587) 
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($cred.UserName, $cred.Password); 
$SMTPClient.Send($SMTPMessage)