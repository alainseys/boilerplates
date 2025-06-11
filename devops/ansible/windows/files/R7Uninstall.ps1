$agentInstalled = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "Rapid7 Insight Agent" }

if ($agentInstalled) {
    $uninstallResult = msiexec.exe /x $($agentInstalled.IdentifyingNumber) /qn
    if ($uninstallResult -eq 0) {
        Write-Output "Rapid7 Insight Agent has been successfully uninstalled."
    } else {
        Write-Output "Failed to uninstall Rapid7 Insight Agent. Exit code: $($uninstallResult)"
    }
} else {
    Write-Output "Rapid7 Insight Agent is not installed on this system."
}
