# ================================
# 🔄 AUTO UPDATE SCRIPT for GoogleAPI-Autopilot
# ================================
$BasePath = "C:\GoogleAPI-Autopilot"
$RepoURL = "https://raw.githubusercontent.com/YourGitHubUsername/GoogleAPI-Autopilot/main"
$BackupPath = "$BasePath\backup\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$ChatToken = "8200662955:AAFBy6ZU5Ny00KTT38QTOoiGMkDe3JY_tGU"
$ChatID = ":5768548408,"

function Send-Telegram {
    param([string]$Message)
    try {
        Invoke-RestMethod -Uri "https://api.telegram.org/bot$ChatToken/sendMessage" `
            -Method Post `
            -Body @{ chat_id = $ChatID; text = $Message } | Out-Null
    } catch { Write-Host "⚠️ Не вдалося надіслати сповіщення Telegram" }
}

Write-Host "===== 🔄 Перевірка оновлень автопілота ====="

# 🗂️ Створення резервної копії
New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
Copy-Item -Path "$BasePath\*" -Destination $BackupPath -Recurse -Force
Write-Host "✅ Резервна копія створена: $BackupPath"

# 📥 Список файлів для оновлення
$files = @(
    "full_autopilot.ps1",
    "full_autopilot_silent.ps1",
    "save_and_setup_autopilot.ps1",
    "run_full_autopilot_auto.bat",
    "check_full_autopilot_status.ps1"
)

$Updated = @()

foreach ($file in $files) {
    $url = "$RepoURL/$file"
    $dest = "$BasePath\$file"
    try {
        $newContent = Invoke-RestMethod -Uri $url -UseBasicParsing
        if ($newContent) {
            Set-Content -Path $dest -Value $newContent -Force
            $Updated += $file
            Write-Host "✅ Оновлено: $file"
        }
    } catch {
        Write-Host "⚠️ Не вдалося оновити $file"
    }
}

if ($Updated.Count -gt 0) {
    $msg = "🔄 Автопілот оновлено на $(Get-Date -Format 'yyyy-MM-dd HH:mm')`n✅ Оновлено файлів: $($Updated -join ', ')"
    Send-Telegram $msg
    Write-Host "`n✅ Оновлення завершено успішно!"
} else {
    Write-Host "`nℹ️ Нових оновлень не знайдено."
    Send-Telegram "ℹ️ Автопілот перевірено — нових оновлень немає."
}
