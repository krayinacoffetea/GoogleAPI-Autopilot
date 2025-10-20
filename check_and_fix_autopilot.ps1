# ==============================
# 🔧 Автоматична перевірка та виправлення автопілота Google API
# ==============================

$BasePath = "C:\GoogleAPI-Autopilot"
$TaskName = "GoogleAPI-Autopilot-FullAuto"
$batFile = "$BasePath\run_full_autopilot_auto.bat"
$allOk = $true

Write-Host "===== Перевірка та виправлення автопілота Google API =====`n"

# 1️⃣ Credentials
if (Test-Path "$BasePath\credentials.xml") {
    Write-Host "✅ credentials.xml знайдено"
} else {
    Write-Host "❌ credentials.xml відсутній. Виконай save_gmail_cred.ps1!"
    $allOk = $false
}

# 2️⃣ BAT-файл
if (-Not (Test-Path $batFile)) {
    Write-Host "⚠️ BAT-файл відсутній. Створюємо..."
    "@echo off`npowershell -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$BasePath\full_autopilot_silent.ps1`"`nexit" | Out-File -FilePath $batFile -Encoding UTF8
    Write-Host "✅ BAT-файл створено: $batFile"
} else {
    Write-Host "✅ BAT-файл знайдено"
}

# 3️⃣ Основні PS1 файли
$psFiles = @("full_autopilot.ps1","full_autopilot_silent.ps1")
foreach ($file in $psFiles) {
    if (Test-Path "$BasePath\$file") {
        Write-Host "✅ $file знайдено"
    } else {
        Write-Host "❌ $file відсутній!"
        $allOk = $false
    }
}

# 4️⃣ Scheduled Task
$task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($task) {
    Write-Host "✅ Завдання '$TaskName' знайдено"
} else {
    Write-Host "⚠️ Завдання не знайдено. Створюємо..."
    $action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c `"$batFile`""
    $trigger1 = New-ScheduledTaskTrigger -Daily -At 7:00AM
    $trigger2 = New-ScheduledTaskTrigger -Daily -At 7:00PM
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew

    try {
        Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger1,$trigger2 -Description "Повний автопілот Google API (07:00 / 19:00)" -User "$env:USERNAME" -RunLevel Highest -Settings $settings
        Write-Host "✅ Scheduled Task створено"
    } catch {
        Write-Host "❌ Помилка створення Scheduled Task: $_"
        $allOk = $false
    }
}

# 5️⃣ Останній лог
$logs = Get-ChildItem "$BasePath\logs" -Filter "*.csv" | Sort-Object LastWriteTime -Descending
if ($logs) {
    Write-Host "✅ Останній лог: $($logs[0].Name)"
    Write-Host "   📅 Дата: $($logs[0].LastWriteTime)"
    Write-Host "   📂 Шлях: $($logs[0].FullName)"
} else {
    Write-Host "❌ Логів не знайдено"
    $allOk = $false
}

# 6️⃣ Тестовий запуск автопілота (silent)
Write-Host "`n🚀 Виконання тестового silent запуску..."
try {
    Start-Process -FilePath $batFile -WindowStyle Hidden -Wait
    Write-Host "✅ Автопілот запущено та завершено без помилок"
} catch {
    Write-Host "❌ Помилка запуску автопілота: $_"
    $allOk = $false
}

# 7️⃣ Підсумковий статус
Write-Host "`n===== Підсумок ====="
if ($allOk) {
    Write-Host "💪 Максимальна продуктивність автопілота: ✅ ВСЕ НАЛАШТОВАНО ПРАВИЛЬНО!"
} else {
    Write-Host "⚠️ Деякі елементи автопілота потребують уваги. Перевір попередні повідомлення."
}
