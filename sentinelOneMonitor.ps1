# Version 1 - Created 18/12/24
# Created by Sufyan Mun

function Check-SentinelOnePresence {
    $Global:SentinelInstalled = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -contains "Sentinel Agent"
    $Global:SentinelService = Get-Service -Name "SentinelAgent" -ErrorAction SilentlyContinue
}

function Output-DRMMAlert ($alertMessage) {
    Write-Host '<-Start Result->'
    Write-Host "ALERT=$alertMessage"
    Write-Host '<-End Result->'
}

function Output-DRMMStatus ($statusMessage) {
    Write-Host '<-Start Result->'
    Write-Host "STATUS=$statusMessage"
    Write-Host '<-End Result->'
}

Check-SentinelOnePresence
if ($SentinelInstalled) {
    Write-Host "-- SentinelOne is installed"
    if ($SentinelService.Status -eq "Running") {
        Write-Host "-- SentinelOne service is active and running"
        Output-DRMMStatus "SentinelOne is installed and operational"
        Exit 0
    } else {
        Write-Host "-- SentinelOne service is not running"
        try {
            $SentinelService | Start-Service -ErrorAction SilentlyContinue
            Check-SentinelOnePresence
            if ($SentinelService.Status -eq "Stopped") {
                Write-Host "-- Failed to restart SentinelOne service"
                Output-DRMMAlert "SentinelOne service is not running and restart attempt was unsuccessful."
                Exit 0
            }
        } catch {
            Write-Host "-- Error encountered while attempting to start SentinelOne service"
            Output-DRMMAlert "Error occurred during SentinelOne service restart."
            Exit 1
        }
    }
} else {
    Write-Host "-- SentinelOne is not installed"
    Output-DRMMAlert "SentinelOne is missing, please investigate"
    Exit 1
}

