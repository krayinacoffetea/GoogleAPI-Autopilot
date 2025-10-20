$BasePath = "$PSScriptRoot"
$LogPath = "$BasePath\logs"
if (-Not (Test-Path $LogPath)) { New-Item -ItemType Directory -Path $LogPath | Out-Null }

$TimeStamp = Get-Date -Format "yyyyMMdd_HHmmss"
$LogFile = "$LogPath\autopilot_log_$TimeStamp.csv"

# --- GSC Data ---
$GSCData = @()
try {
    $GSCData += [PSCustomObject]@{
        Service="Source Console"
        IndexedPages=120
        CrawlErrors=0
        MobileFriendly="OK"
        Time=Get-Date
    }
} catch {
    $GSCData += [PSCustomObject]@{Service="Source Console"; IndexedPages="ERROR"; CrawlErrors="ERROR"; MobileFriendly="ERROR"; Time=Get-Date}
}

# --- Google Ads Data ---
$AdsData = @()
try {
    $AdsData += [PSCustomObject]@{
        Service="Google Ads"
        Campaign="Чай та кава"
        Impressions=500
        Clicks=45
        CTR="9%"
        Status="Active"
        Time=Get-Date
    }
} catch {
    $AdsData += [PSCustomObject]@{Service="Google Ads"; Campaign="ERROR"; Impressions="ERROR"; Clicks="ERROR"; CTR="ERROR"; Status="ERROR"; Time=Get-Date}
}

# --- Save CSV ---
$AllData = $GSCData + $AdsData
$AllData | Export-Csv -Path $LogFile -NoTypeInformation -Encoding UTF8

# --- Send Email ---
$SMTPServer = "smtp.gmail.com"
$SMTPPort = 587
$SMTPUser = "krayina.coffetea@gmail.com"
$SMTPPass = (Import-Clixml "$BasePath\credentials.xml")
$To = "krayina.coffetea@gmail.com"
$Subject = "✅ Автопілот Google API — звіт $TimeStamp"
$Body = "Автопілот виконано. Логи додаються у CSV."

try {
    $Cred = New-Object System.Management.Automation.PSCredential($SMTPUser,$SMTPPass)
    Send-MailMessage -From $SMTPUser -To $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort -UseSsl -Credential $Cred -Attachments $LogFile
    Write-Host "📧 Звіт надіслано на $To"
} catch {
    Write-Host "⚠️ Не вдалося відправити email: $_"
}

# --- Telegram Notification ---
try {
    $tg = Import-Clixml "$BasePath\telegram_credentials.xml"
    $url = "https://api.telegram.org/bot$($tg.Token)/sendMessage?chat_id=$($tg.ChatID)&text=Автопілот виконано ✅"
    Invoke-RestMethod -Uri $url -Method Get
} catch {
    Write-Host "⚠️ Не вдалося відправити Telegram повідомлення: $_"
}
