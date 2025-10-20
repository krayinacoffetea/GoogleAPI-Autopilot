@echo off
REM ==============================
REM Автопілот GoogleAPI-FullAuto з логами
REM ==============================

REM 1. Оновлення скриптів
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$repo='https://raw.githubusercontent.com/ТВОЙ_ГІТХАБ/GoogleAPI-Autopilot/main/'; ^
    $files=@('full_autopilot.ps1','full_autopilot_silent.ps1','save_gmail_cred.ps1','send_autopilot_report.ps1'); ^
    foreach($f in $files){Invoke-WebRequest $repo+$f -OutFile 'C:\GoogleAPI-Autopilot\'+$f -UseBasicParsing; Write-Host '✅ Оновлено:' $f}"

REM 2. Запуск автопілота
start "" /min powershell -NoProfile -ExecutionPolicy Bypass -File "C:\GoogleAPI-Autopilot\full_autopilot_silent.ps1"

REM 3. Логи і звіти
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\GoogleAPI-Autopilot\send_autopilot_report.ps1"
