<#
.SYNOPSIS
    Disables GameViewer, MuMu, and Oray virtual display adapters.

.DESCRIPTION
    Finds the following Plug and Play devices and disables them when enabled:
      1. GameViewer Virtual Display Adapter
      2. MuMu Virtual Display Adapter
      3. OrayIddDriver Device

    A device is considered disabled when DEVPKEY_Device_ProblemCode is 22
    (CM_PROB_DISABLED).

.NOTES
    Requires administrator privileges. The script automatically requests UAC
    elevation when necessary. It is idempotent and suitable for scheduled tasks.
    Exit codes: 0 = success or no action required; 1 = failure or manual review.
#>

$targetNames = @(
    'GameViewer Virtual Display Adapter',
    'MuMu Virtual Display Adapter',
    'OrayIddDriver Device'
)

# Relaunch elevated when necessary.
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Administrator privileges are required. Requesting elevation (UAC)...' -ForegroundColor Yellow
    Start-Process -FilePath 'powershell.exe' -Verb RunAs -Wait `
        -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"")
    exit
}

$results = New-Object System.Collections.Generic.List[object]
$hasIssue = $false

foreach ($name in $targetNames) {
    $devices = @(Get-PnpDevice -PresentOnly | Where-Object { $_.FriendlyName -eq $name })

    if ($devices.Count -eq 0) {
        $results.Add([pscustomobject]@{
            Device = $name
            InstanceId = '-'
            Result = 'Not found (device not present or not installed)'
        })
        continue
    }

    foreach ($dev in $devices) {
        $code = (Get-PnpDeviceProperty -InstanceId $dev.InstanceId -KeyName 'DEVPKEY_Device_ProblemCode').Data

        if ($code -eq 22) {
            $results.Add([pscustomobject]@{
                Device = $dev.FriendlyName
                InstanceId = $dev.InstanceId
                Result = 'Already disabled; no action needed'
            })
            continue
        }

        try {
            Disable-PnpDevice -InstanceId $dev.InstanceId -Confirm:$false -ErrorAction Stop
            # Verify that the device actually entered the disabled state.
            $codeAfter = (Get-PnpDeviceProperty -InstanceId $dev.InstanceId -KeyName 'DEVPKEY_Device_ProblemCode').Data
            if ($codeAfter -eq 22) {
                $results.Add([pscustomobject]@{
                    Device = $dev.FriendlyName
                    InstanceId = $dev.InstanceId
                    Result = 'Successfully disabled'
                })
            }
            else {
                $hasIssue = $true
                $results.Add([pscustomobject]@{
                    Device = $dev.FriendlyName
                    InstanceId = $dev.InstanceId
                    Result = "ProblemCode=$codeAfter after disabling; manual review required"
                })
            }
        }
        catch {
            $hasIssue = $true
            $results.Add([pscustomobject]@{
                Device = $dev.FriendlyName
                InstanceId = $dev.InstanceId
                Result = "Failed to disable: $($_.Exception.Message)"
            })
        }
    }
}

Write-Host ''
Write-Host '===== Virtual display adapter results =====' -ForegroundColor Cyan
$results | Format-Table -AutoSize

exit ($(if ($hasIssue) { 1 } else { 0 }))
