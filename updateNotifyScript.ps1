$version = read-host -Prompt 'Server Version Number' 
$Date = get-date 
$pwd = ConvertTo-SecureString "<<key>>" -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential ("SMTP_Injection", $pwd)
$subject = @('Update Scheduled', 'Update Complete')
$body = @("ALCON,`n`nThere is an update available! The server will be down for approx. 30 minutes starting at $date. We will notify you when updates are complete!$Signature",
"ALCON,`n`nThe update to $version is complete! Please clear your cache and close your browser for all changes to apply. If there are any issues or concerns, contact IT Support for assistance.$Signature")
$to = <<toEmail>>

#Sends Email to end users for Notification of the update
function startEmail() {
    Send-MailMessage -From <<Email>> -To $to -Subject $subject[0] `
    -Body $body[0] `
    -SmtpServer <<SMTP RELAY>> -Port 587 -Credential $creds -UseSsl
}

#Check for any potential Database updates with the coming version. Calls runUpdate.
function dbUpdate() {
    .\callsql.bat
    pause
    $answer = read-host -Prompt "Is there a DB query for the update? (y/n)"
    if ($answer -eq 'y') {
        $query = read-host -Prompt "Please enter your query here"
        SQLCMD -S .\instanceName -q $query
    }else {
        runUpdate     
    }
}

#Interacts with GIT-Bash terminal to run git Pull 
function runUpdate() {
    start-process { C:\Program Files\Git\git-bash.exe }
    sleep 30 #waits for terminal to be operational
    $wshell = New-Object -ComObject wscript.shell;
    $wshell.AppActivate('MINGW64:/p/')    
    $wshell.SendKeys('cd /d/app')
    $wshell.SendKeys('{ENTER}')
    sleep 1
    $wshell.SendKeys('git pull rep')
    sleep 1
    $wshell.SendKeys('{ENTER}')
    sleep 10
    $wshell.SendKeys('exit')
    $wshell.SendKeys('{ENTER}')
    Start-Sleep 3
    finishEmail
}

#Sends Email to end users for completion of the update
function finishEmail() {
    Send-MailMessage -From <<email>> -To $to -Subject $subject[1] `
    -Body $body[1] `
    -SmtpServer <<SMTP Relay>> -Port 587 -Credential $creds -UseSsl
}
