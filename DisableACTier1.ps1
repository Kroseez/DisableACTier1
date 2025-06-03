# Import module ActiveDirectory
Import-Module ActiveDirectory

# Function settings
$Server = "Your DC Server" # DNS Name Your DC Server
$SearchBase = "ou=,ou=,dc=domain,dc=com" # Your ou with fired accounts
$DateFormat = "MM/dd/yyyy"
$LogFile = "C:\Logs\ADUserUpdate_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Create log file if it does not exist
if (-not (Test-Path (Split-Path $LogFile -Parent))) {
    New-Item -ItemType Directory -Path (Split-Path $LogFile -Parent) | Out-Null
}

# Function to check date format
function Test-DateFormat {
    param (
        [string]$DateString,
        [string]$Format
    )
    $Date = [DateTime]::MinValue
    return [DateTime]::TryParseExact($DateString, $Format, $null, [System.Globalization.DateTimeStyles]::None, [ref]$Date)
}

# Logging
function Write-Log {
    param (
        [string]$Message
    )
    $LogMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
    Write-Output $LogMessage | Out-File -FilePath $LogFile -Append
}

try {
    # Getting all users from an OU
    $Users = Get-ADUser -Server $Server -SearchBase $SearchBase -Filter * -Properties Description -ErrorAction Stop

    foreach ($User in $Users) {
        try {
            if ($User.Enabled) {
                # Disabling active accounts and setting the current date
                $CurrentDate = Get-Date -Format $DateFormat
                Set-ADUser -Identity $User -Description $CurrentDate -ErrorAction Stop
                Disable-ADAccount -Identity $User -ErrorAction Stop
                Write-Log "User $($User.SamAccountName) disabled and Description set to $CurrentDate"
            }
            elseif (-not (Test-DateFormat -DateString $User.Description -Format $DateFormat)) {
                # Update Description for disabled accounts with incorrect date
                $CurrentDate = Get-Date -Format $DateFormat
                Set-ADUser -Identity $User -Description $CurrentDate -ErrorAction Stop
                Write-Log "User $($User.SamAccountName) Description updated to $CurrentDate"
            }
        }
        catch {
            Write-Log "Error processing user $($User.SamAccountName): $($_.Exception.Message)"
        }
    }
}
catch {
    Write-Log "Error retrieving users from AD: $($_.Exception.Message)"
}
finally {
    Write-Log "Script execution completed."
}